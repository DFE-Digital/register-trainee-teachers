import secrets from "k6/secrets";
import { client } from "../client.ts";

/**
 * update
 */
export default async (traineeId?: string, placementId?: string) => {
  const apiVersion = "v2025.0-rc"
  const apiKey     = __ENV.auth_token || await secrets.get("apiKey");

  traineeId   ||= await secrets.get("traineeId");
  placementId ||= await secrets.get("placementId");

  const putApiApiVersionTraineesTraineeIdPlacementsPlacementIdBody = {
    data: {
      urn: "100000",
    },
  };

  return client.putApiApiVersionTraineesTraineeIdPlacementsPlacementId(
      apiVersion,
      traineeId,
      placementId,
      putApiApiVersionTraineesTraineeIdPlacementsPlacementIdBody,
      {
        headers: { "Authorization": `Bearer ${apiKey}`}
      }
    );
}
