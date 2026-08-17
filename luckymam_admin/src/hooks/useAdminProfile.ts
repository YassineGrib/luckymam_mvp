import { useCallback, useMemo, useState } from "react";
import {
  EmailAuthProvider,
  reauthenticateWithCredential,
  updatePassword,
  updateProfile,
} from "firebase/auth";

import { useAuth } from "@/components/admin/AuthProvider";
import { auth } from "@/lib/firebase";
import {
  adminInitials,
  resolveAdminDisplayName,
} from "@/lib/adminProfile";

export function useAdminProfile() {
  const { user } = useAuth();
  const [displayNameOverride, setDisplayNameOverride] = useState<string | null>(
    null,
  );

  const displayName = useMemo(() => {
    if (displayNameOverride) return displayNameOverride;
    return resolveAdminDisplayName(user);
  }, [displayNameOverride, user]);

  const email = user?.email ?? "";
  const initials = useMemo(() => adminInitials(displayName), [displayName]);

  const updateDisplayName = useCallback(async (name: string) => {
    const currentUser = auth.currentUser;
    if (!currentUser) throw new Error("NOT_SIGNED_IN");

    const trimmed = name.trim();
    if (!trimmed) throw new Error("NAME_REQUIRED");

    await updateProfile(currentUser, { displayName: trimmed });
    await currentUser.reload();
    setDisplayNameOverride(trimmed);
  }, []);

  const changePassword = useCallback(
    async (currentPassword: string, newPassword: string) => {
      const currentUser = auth.currentUser;
      if (!currentUser?.email) throw new Error("NOT_SIGNED_IN");

      if (newPassword.length < 6) throw new Error("PASSWORD_TOO_SHORT");

      const credential = EmailAuthProvider.credential(
        currentUser.email,
        currentPassword,
      );
      await reauthenticateWithCredential(currentUser, credential);
      await updatePassword(currentUser, newPassword);
    },
    [],
  );

  return {
    displayName,
    email,
    initials,
    updateDisplayName,
    changePassword,
  };
}
