import React, { createContext, useContext, useEffect, useState } from "react";
import { onAuthStateChanged, signOut, type User } from "firebase/auth";
import { auth } from "@/lib/firebase";
import { useRouterState, useNavigate } from "@tanstack/react-router";

export type AuthStatus = "loading" | "signed-out" | "signed-in-not-admin" | "admin";

interface AuthContextType {
  status: AuthStatus;
  user: User | null;
  signOutUser: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [status, setStatus] = useState<AuthStatus>("loading");
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (currentUser) => {
      if (!currentUser) {
        setUser(null);
        setStatus("signed-out");
        return;
      }
      try {
        // Force refresh ID token to load the latest custom claims (like admin: true)
        const tokenResult = await currentUser.getIdTokenResult(true);
        const isAdmin = tokenResult.claims.admin === true;
        setUser(currentUser);
        setStatus(isAdmin ? "admin" : "signed-in-not-admin");
      } catch (err) {
        console.error("Error retrieving ID token claims:", err);
        setUser(null);
        setStatus("signed-out");
      }
    });
    return unsubscribe;
  }, []);

  const signOutUser = async () => {
    await signOut(auth);
  };

  return (
    <AuthContext.Provider value={{ status, user, signOutUser }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) throw new Error("useAuth must be used within AuthProvider");
  return context;
}

export function AuthGuard({ children }: { children: React.ReactNode }) {
  const { status } = useAuth();
  const routerState = useRouterState();
  const navigate = useNavigate();
  const pathname = routerState.location.pathname;

  useEffect(() => {
    if (status === "loading") return;

    if (pathname === "/login") {
      if (status === "admin") {
        navigate({ to: "/" });
      }
    } else {
      if (status !== "admin") {
        navigate({
          to: "/login",
          search: status === "signed-in-not-admin" ? { reason: "not-admin" } : {},
        });
      }
    }
  }, [status, pathname, navigate]);

  if (status === "loading") {
    return (
      <div className="min-h-screen flex items-center justify-center bg-background text-sm text-ink-muted">
        جاري التحميل...
      </div>
    );
  }

  // Prevent protected UI flashing during redirect
  if (pathname !== "/login" && status !== "admin") {
    return null;
  }

  // Prevent login page flashing during redirect
  if (pathname === "/login" && status === "admin") {
    return null;
  }

  return <>{children}</>;
}
