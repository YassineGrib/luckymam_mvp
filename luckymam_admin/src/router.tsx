import { QueryClient } from "@tanstack/react-query";
import { createRouter } from "@tanstack/react-router";
import { routeTree } from "./routeTree.gen";

export const getRouter = () => {
  const queryClient = new QueryClient();

  const rawBase = import.meta.env.BASE_URL ?? "/";
  const basepath = rawBase.endsWith("/") && rawBase.length > 1 ? rawBase.slice(0, -1) : undefined;

  const router = createRouter({
    routeTree,
    context: { queryClient },
    basepath,
    scrollRestoration: true,
    defaultPreloadStaleTime: 0,
  });

  return router;
};
