import { randomInt } from 'crypto';

/**
 * Maximum length of the vet code name prefix (keeps codes short, e.g. SOKHA-4827).
 */
const MAX_VET_CODE_PREFIX_LENGTH = 8;

/**
 * Fallback prefix used when a name cannot produce a suitable Latin prefix
 * (e.g. Khmer-only names). The 4-digit number is still required.
 */
export const VET_CODE_FALLBACK_PREFIX = 'VET';

/**
 * Title prefixes that are removed from the name before building the code prefix.
 */
const VET_CODE_TITLE_PATTERNS = [
  /^DR\b\.?\s*/i,
  /^DOCTOR\b\.?\s*/i,
  /^វេជ្ជបណ្ឌិត\s*/, // Khmer for "doctor"
];

/**
 * Builds a clean, short, uppercase Latin prefix from a veterinarian name.
 *
 * Examples:
 *   "Dr. Sokha Chan" -> "SOKHA"
 *   "Dr. Dara"       -> "DARA"
 *   "Dara Kim"       -> "DARA"
 *   "សុខា"            -> "VET" (fallback, no Latin letters available)
 */
export function generateVetCodePrefix(name: string): string {
  if (!name || typeof name !== 'string') {
    return VET_CODE_FALLBACK_PREFIX;
  }

  // 1. Uppercase so title prefixes match regardless of the original casing.
  let cleaned = name.trim().toUpperCase();

  // 2. Remove title prefixes ("Dr.", "Dr", "Doctor", Khmer title) when present.
  for (const pattern of VET_CODE_TITLE_PATTERNS) {
    cleaned = cleaned.replace(pattern, '');
  }

  // 3. Remove special characters / digits / Khmer characters: keep only
  //    Latin letters, everything else acts as a separator.
  cleaned = cleaned.replace(/[^A-Z]+/g, ' ').trim();

  if (!cleaned) {
    return VET_CODE_FALLBACK_PREFIX;
  }

  // 4. Use the first meaningful token (>= 2 letters) and keep it short.
  const tokens = cleaned.split(/\s+/).filter((token) => token.length >= 2);
  const prefix = (tokens[0] ?? VET_CODE_FALLBACK_PREFIX).slice(
    0,
    MAX_VET_CODE_PREFIX_LENGTH,
  );

  return prefix.length >= 2 ? prefix : VET_CODE_FALLBACK_PREFIX;
}

/**
 * Builds a complete vet code: PREFIX-1234 (e.g. "SOKHA-4827").
 *
 * The 4 digits are randomly generated. Uniqueness against the database is
 * the caller's responsibility (see UsersService.ensureVetCode which retries
 * on collisions and on unique-constraint conflicts).
 */
export function generateVetCode(name: string): string {
  const prefix = generateVetCodePrefix(name);
  const digits = randomInt(1000, 10000).toString().padStart(4, '0');
  return `${prefix}-${digits}`;
}

/**
 * Normalizes user input before searching: trims spaces, removes all
 * internal whitespace and uppercases the code.
 *
 * Example: " sokha-4827 " -> "SOKHA-4827"
 */
export function normalizeVetCode(input: string): string {
  if (!input || typeof input !== 'string') {
    return '';
  }
  return input.replace(/\s+/g, '').toUpperCase();
}
