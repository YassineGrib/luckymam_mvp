import { createFileRoute, Navigate } from "@tanstack/react-router";

export const Route = createFileRoute("/album-claims")({
  component: () => <Navigate to="/print-orders" replace />,
});
