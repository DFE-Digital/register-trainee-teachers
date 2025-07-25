import secrets from "k6/secrets";
import { client } from "../client.ts";

/**
 * create
 */
export default async (traineeId?: string): Promise<string> => {
  const apiVersion = "v2025.0-rc"
  const apiKey     = __ENV.AUTH_TOKEN || await secrets.get("apiKey");

  traineeId ||= await secrets.get("traineeId");

  const postApiApiVersionTraineesTraineeIdPlacementsBody = {
    data: {
      urn: "151631",
    },
  };

  return client.postApiApiVersionTraineesTraineeIdPlacements(
    apiVersion,
    traineeId,
    postApiApiVersionTraineesTraineeIdPlacementsBody,
    {
      headers: { "Authorization": `Bearer ${apiKey}`}
    }
  ).response.json().data.placement_id;
}
