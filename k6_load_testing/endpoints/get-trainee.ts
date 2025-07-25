import secrets from "k6/secrets";
import { client } from "../client.ts";

/**
 * show
 */
export default async (traineeId?: string) => {
  const apiVersion = "v2025.0-rc"
  const apiKey     = __ENV.AUTH_TOKEN || await secrets.get("apiKey");

  traineeId ||= await secrets.get("traineeId");

  return client.getApiApiVersionTraineesTraineeId(
    apiVersion,
    traineeId,
    {
      headers: { "Authorization": `Bearer ${apiKey}`}
    }
  );
}
