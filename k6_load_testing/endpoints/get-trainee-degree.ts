import secrets from "k6/secrets";
import { client } from "../client.ts";

/**
 * show
 */
export default async (traineeId?: string, degreeId?: string) => {
  const apiVersion = "v2025.0-rc"
  const apiKey     = __ENV.AUTH_TOKEN || await secrets.get("apiKey");

  traineeId ||= await secrets.get("traineeId");
  degreeId  ||= await secrets.get("degreeId");

  return client.getApiApiVersionTraineesTraineeIdDegreesDegreeId(
    apiVersion,
    traineeId,
    degreeId,
    {
      headers: { "Authorization": `Bearer ${apiKey}`}
    }
  );
}
