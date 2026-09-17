import {
  generateVetCode,
  generateVetCodePrefix,
  normalizeVetCode,
  VET_CODE_FALLBACK_PREFIX,
} from './vet-code.util';

describe('vet-code.util', () => {
  describe('generateVetCodePrefix', () => {
    it('removes "Dr." and uses the first meaningful name', () => {
      expect(generateVetCodePrefix('Dr. Sokha Chan')).toBe('SOKHA');
      expect(generateVetCodePrefix('Dr. Sokha')).toBe('SOKHA');
    });

    it('removes "Dr" and "Doctor" prefixes', () => {
      expect(generateVetCodePrefix('Dr Sokha')).toBe('SOKHA');
      expect(generateVetCodePrefix('doctor Dara Kim')).toBe('DARA');
    });

    it('uppercases and uses the first name', () => {
      expect(generateVetCodePrefix('Dara Kim')).toBe('DARA');
      expect(generateVetCodePrefix('sreypy chan')).toBe('SREYPY');
    });

    it('keeps the prefix short', () => {
      const prefix = generateVetCodePrefix('Maximilianathan Sokha');
      expect(prefix.length).toBeLessThanOrEqual(8);
    });

    it('falls back to VET for Khmer-only names', () => {
      expect(generateVetCodePrefix('សុខា')).toBe(VET_CODE_FALLBACK_PREFIX);
    });

    it('falls back to VET for empty or special-character names', () => {
      expect(generateVetCodePrefix('')).toBe(VET_CODE_FALLBACK_PREFIX);
      expect(generateVetCodePrefix('1234 !!!')).toBe(VET_CODE_FALLBACK_PREFIX);
      expect(generateVetCodePrefix('Dr. 123')).toBe(VET_CODE_FALLBACK_PREFIX);
    });
  });

  describe('generateVetCode', () => {
    it('produces the PREFIX-1234 format', () => {
      const code = generateVetCode('Dr. Sokha');
      expect(code).toMatch(/^[A-Z]{1,8}-\d{4}$/);
      expect(code.startsWith('SOKHA-')).toBe(true);
    });

    it('uses the VET fallback prefix with 4 digits', () => {
      const code = generateVetCode('សុខា');
      expect(code).toMatch(/^VET-\d{4}$/);
    });

    it('generates a valid format for many random names', () => {
      for (let i = 0; i < 50; i++) {
        expect(generateVetCode('Dr. Test')).toMatch(/^[A-Z]{1,8}-\d{4}$/);
      }
    });
  });

  describe('normalizeVetCode', () => {
    it('trims spaces and uppercases', () => {
      expect(normalizeVetCode(' sokha-4827 ')).toBe('SOKHA-4827');
      expect(normalizeVetCode('sokha-4827')).toBe('SOKHA-4827');
      expect(normalizeVetCode('DARA-9134')).toBe('DARA-9134');
    });

    it('removes internal whitespace', () => {
      expect(normalizeVetCode('sokha - 4827')).toBe('SOKHA-4827');
    });

    it('handles empty input safely', () => {
      expect(normalizeVetCode('')).toBe('');
      expect(normalizeVetCode('   ')).toBe('');
    });
  });
});
