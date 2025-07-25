import secrets from "k6/secrets";
import { client } from "../client.ts";

/**
 * show
 */
export default async (traineeId?: string, placementId?: string) => {
  const apiVersion = "v2025.0-rc"
  const apiKey     = __ENV.AUTH_TOKEN || await secrets.get("apiKey");

  traineeId   ||= await secrets.get("traineeId");
  placementId ||= await secrets.get("placementId");

  return client.getApiApiVersionTraineesTraineeIdPlacementsPlacementId(
    apiVersion,
    traineeId,
    placementId,
    {
      headers: { "Authorization": `Bearer ${apiKey}`}
    }
  );
}
