import { UsersService } from './users.service';
import { User, UserRole } from './entities/user.entity';
import { generateVetCode } from './utils/vet-code.util';

describe('UsersService.ensureVetCode', () => {
  const makeUser = (overrides: Partial<User> = {}): User =>
    ({
      user_id: 1,
      name: 'Dr. Sokha',
      phone: '+855100000001',
      role: UserRole.VETERINARIAN,
      ...overrides,
    }) as User;

  const buildService = () => {
    const savedCodes: string[] = [];

    const userRepository = {
      // Simulates the database: a code exists when it was already saved.
      findOne: jest.fn(async ({ where }: any) =>
        savedCodes.includes(where.vet_code) ? { user_id: 99 } : null,
      ),
      save: jest.fn(async (user: User) => {
        savedCodes.push(user.vet_code as string);
        return user;
      }),
    };

    const connectionRepository = { findOne: jest.fn(), save: jest.fn() };

    const service = new UsersService(
      userRepository as any,
      connectionRepository as any,
      {} as any,
      { createConnectionRequestNotification: jest.fn() } as any,
    );

    return { service, userRepository, savedCodes };
  };

  it('generates a PREFIX-1234 code for a new veterinarian', async () => {
    const { service } = buildService();
    const user = makeUser();

    await service.ensureVetCode(user);

    expect(user.vet_code).toMatch(/^SOKHA-\d{4}$/);
  });

  it('gives two veterinarians with the same name different codes', async () => {
    const { service, userRepository } = buildService();

    const vetA = makeUser({ user_id: 1, phone: '+855100000001' });
    const vetB = makeUser({ user_id: 2, phone: '+855100000002' });

    await service.ensureVetCode(vetA);
    await service.ensureVetCode(vetB);

    expect(vetA.vet_code).toMatch(/^SOKHA-\d{4}$/);
    expect(vetB.vet_code).toMatch(/^SOKHA-\d{4}$/);
    expect(vetA.vet_code).not.toBe(vetB.vet_code);
    // The second vet had at least one DB lookup (uniqueness check).
    expect(userRepository.findOne).toHaveBeenCalled();
  });

  it('never regenerates a code for a vet that already has one', async () => {
    const { service, userRepository } = buildService();
    const user = makeUser({ vet_code: 'SOKHA-4827' });

    await service.ensureVetCode(user);

    expect(user.vet_code).toBe('SOKHA-4827');
    expect(userRepository.findOne).not.toHaveBeenCalled();
    expect(userRepository.save).not.toHaveBeenCalled();
  });

  it('does nothing for farmers', async () => {
    const { service, userRepository } = buildService();
    const farmer = makeUser({ role: UserRole.FARMER });

    await service.ensureVetCode(farmer);

    expect(farmer.vet_code).toBeUndefined();
    expect(userRepository.save).not.toHaveBeenCalled();
  });

  it('retries and stays unique when the DB reports a constraint violation', async () => {
    const savedCodes: string[] = [];

    const userRepository = {
      findOne: jest.fn(async ({ where }: any) =>
        savedCodes.includes(where.vet_code) ? { user_id: 99 } : null,
      ),
      // First save always conflicts (simulating a concurrent registration),
      // afterwards it behaves like the database.
      save: jest
        .fn()
        .mockImplementationOnce(async (user: User) => {
          savedCodes.push(user.vet_code as string);
          const conflict = new Error('duplicate key');
          (conflict as any).code = '23505';
          throw conflict;
        })
        .mockImplementation(async (user: User) => {
          savedCodes.push(user.vet_code as string);
          return user;
        }),
    };

    const service = new UsersService(
      userRepository as any,
      { findOne: jest.fn(), save: jest.fn() } as any,
      {} as any,
      { createConnectionRequestNotification: jest.fn() } as any,
    );

    const user = makeUser();
    await service.ensureVetCode(user);

    expect(user.vet_code).toMatch(/^SOKHA-\d{4}$/);
    expect(userRepository.save).toHaveBeenCalledTimes(2);
    // The retried code must be different from the conflicting one.
    expect(savedCodes[0]).not.toBe(savedCodes[1]);
  });

  it('produces valid codes through the util for same-name vets', () => {
    const a = generateVetCode('Dr. Sokha');
    const b = generateVetCode('Dr. Sokha');
    expect(a).toMatch(/^SOKHA-\d{4}$/);
    expect(b).toMatch(/^SOKHA-\d{4}$/);
    // Not guaranteed different by design (random), uniqueness is enforced by
    // ensureVetCode against the DB; this just documents the format contract.
  });
});
