import { onRequest } from "firebase-functions/v2/https";
import { handler as nitroHandler } from "./admin-server/index.mjs";

function firebaseRequestToAwsEvent(req) {
  const headers = { ...req.headers };
  const host = headers.host || headers.Host || "luckymam-app-dv.web.app";
  delete headers.host;
  delete headers.Host;

  const path = req.originalUrl?.split("?")[0] || req.path || "/";
  const query = req.originalUrl?.includes("?")
    ? req.originalUrl.split("?").slice(1).join("?")
    : new URLSearchParams(req.query).toString();

  let body;
  let isBase64Encoded = false;
  if (req.method !== "GET" && req.method !== "HEAD" && req.rawBody?.length) {
    body = req.rawBody.toString("base64");
    isBase64Encoded = true;
  }

  return {
    httpMethod: req.method,
    path,
    rawPath: path,
    rawQueryString: query,
    headers,
    queryStringParameters: req.query,
    body,
    isBase64Encoded,
    requestContext: {
      domainName: host,
      http: { method: req.method },
    },
  };
}

function sendAwsResponse(res, result) {
  res.status(result.statusCode);

  for (const [key, value] of Object.entries(result.headers || {})) {
    res.set(key, value);
  }

  if (result.multiValueHeaders?.["set-cookie"]) {
    res.set("Set-Cookie", result.multiValueHeaders["set-cookie"]);
  } else if (result.cookies?.length) {
    res.set("Set-Cookie", result.cookies);
  }

  if (result.isBase64Encoded) {
    res.send(Buffer.from(result.body || "", "base64"));
    return;
  }

  res.send(result.body ?? "");
}

export const adminSsr = onRequest(
  {
    region: "us-central1",
    memory: "512MiB",
    timeoutSeconds: 60,
    minInstances: 0,
    maxInstances: 10,
  },
  async (req, res) => {
    try {
      const event = firebaseRequestToAwsEvent(req);
      const result = await nitroHandler(event, {});
      sendAwsResponse(res, result);
    } catch (error) {
      console.error("[adminSsr]", error);
      res.status(500).send("Internal Server Error");
    }
  },
);
