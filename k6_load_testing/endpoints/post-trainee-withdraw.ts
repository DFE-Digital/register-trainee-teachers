import { client } from "../client.ts";
import { setup as loadSetup, SetupData } from "../setup.ts";

export async function setup(): Promise<SetupData> {
  return await loadSetup();
}

/**
 * create
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
