import secrets from "k6/secrets";
import { client } from "../client.ts";

/**
 * create
 */
export default async (traineeId?: string) => {
  const apiVersion = "v2025.0-rc"
  const apiKey     = __ENV.auth_token || await secrets.get("apiKey");

  traineeId   ||= await secrets.get("traineeId");

  const postApiApiVersionTraineesTraineeIdWithdrawBody = {
    data: {
      reasons: ["record_added_in_error"],
      withdraw_date: "2025-07-23",
      trigger: "provider",
      future_interest: "no"
    }
  };

  return client.postApiApiVersionTraineesTraineeIdWithdraw(
    apiVersion,
    traineeId,
    postApiApiVersionTraineesTraineeIdWithdrawBody,
    {
      headers: { "Authorization": `Bearer ${apiKey}`}
    }
  );
}
