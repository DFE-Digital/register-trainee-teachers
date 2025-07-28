import client from "../client.ts";
import { setup as loadSetup, SetupData } from "../setup.ts";

export function setup(): Promise<SetupData> {
  return loadSetup();
}

/**
 * POST /api/{apiVersion}/trainees/{traineeId}/defer
 */
export default ({apiVersion, apiKey, traineeId}: SetupData) => {
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
