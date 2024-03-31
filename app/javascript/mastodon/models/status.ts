export type StatusVisibility =
  | 'public'
  | 'unlisted'
  | 'private'
  | 'direct'
  | 'public_unlisted'
  | 'login'
  | 'mutual'
  | 'circle'
  | 'personal'
  | 'reply'
  | 'limited';

// Temporary until we type it correctly
export type Status = Immutable.Map<string, unknown>;
