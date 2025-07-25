import secrets from "k6/secrets";
import { client } from "../client.ts";

/**
 * create
 */
export default async (traineeId?: string) => {
  const apiVersion = "v2025.0-rc"
  const apiKey     = __ENV.auth_token || await secrets.get("apiKey");

  traineeId ||= await secrets.get("traineeId");

  const postApiApiVersionTraineesTraineeIdDeferBody = {
    data: {
      defer_date: "2025-07-21",
    },
  };

  return client.postApiApiVersionTraineesTraineeIdDefer(
    apiVersion,
    traineeId,
    postApiApiVersionTraineesTraineeIdDeferBody,
    {
      headers: { "Authorization": `Bearer ${apiKey}`}
    }
  );
}
