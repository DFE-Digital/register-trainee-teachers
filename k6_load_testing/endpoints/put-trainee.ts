import secrets from "k6/secrets";
import { client } from "../client.ts";

/**
 * update
 */
export default async (traineeId?: string) => {
  const apiVersion = "v2025.0-rc"
  const apiKey     = __ENV.auth_token || await secrets.get("apiKey");

  traineeId ||= await secrets.get("traineeId");

  const putApiApiVersionTraineesTraineeIdBody = {
    data: {
      first_names: "Alice",
    },
  };

  return client.putApiApiVersionTraineesTraineeId(
    apiVersion,
    traineeId,
    putApiApiVersionTraineesTraineeIdBody,
    {
      headers: { "Authorization": `Bearer ${apiKey}`}
    }
  );
}
