import secrets from "k6/secrets";
import { client } from "../client.ts";

/**
 * destroy
 */
export default async (traineeId?: string, placementId?: string) => {
  const apiVersion = "v2025.0-rc"
  const apiKey     = __ENV.auth_token || await secrets.get("apiKey");

  traineeId   ||= await secrets.get("traineeId");
  placementId ||= await secrets.get("placementId");

  return client.deleteApiApiVersionTraineesTraineeIdPlacementsPlacementId(
    apiVersion,
    traineeId,
    placementId,
    {
      headers: { "Authorization": `Bearer ${apiKey}`}
    }
  );
}
