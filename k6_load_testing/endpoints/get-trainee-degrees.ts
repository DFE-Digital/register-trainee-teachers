import secrets from "k6/secrets";
import { client } from "../client.ts";

/**
 * index
 */
export default async (traineeId?: string) => {
  const apiVersion = "v2025.0-rc"
  const apiKey     = __ENV.auth_token || await secrets.get("apiKey");

  traineeId ||= await secrets.get("traineeId");

  return client.getApiApiVersionTraineesTraineeIdDegrees(
    apiVersion,
    traineeId,
    {
      headers: { "Authorization": `Bearer ${apiKey}`}
    }
  );
}
