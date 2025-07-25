import secrets from "k6/secrets";
import { client } from "../client.ts";

/**
 * index
 */
export default async () => {
  const apiVersion = "v2025.0-rc"
  const apiKey     = __ENV.AUTH_TOKEN || await secrets.get("apiKey");

  return client.getApiApiVersionTrainees(
    apiVersion,
    undefined,
    {
      headers: { "Authorization": `Bearer ${apiKey}`}
    }
  );
}
