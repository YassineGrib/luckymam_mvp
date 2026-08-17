import type { User } from "firebase/auth";

export const DEFAULT_ADMIN_DISPLAY_NAME = "Admin";

export function resolveAdminDisplayName(user: User | null): string {
  const fromProfile = user?.displayName?.trim();
  if (fromProfile) return fromProfile;

  const email = user?.email?.trim();
  if (email) {
    const local = email.split("@")[0] ?? "";
    if (local) {
      return local.charAt(0).toUpperCase() + local.slice(1);
    }
  }

  return DEFAULT_ADMIN_DISPLAY_NAME;
}

export function adminInitials(displayName: string): string {
  const parts = displayName.trim().split(/\s+/).filter(Boolean);
  if (parts.length === 0) return "AD";
  if (parts.length === 1) return parts[0].substring(0, 2).toUpperCase();
  return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
}
