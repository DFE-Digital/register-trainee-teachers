import { client } from "../client.ts";
import { setup as loadSetup, SetupData } from "../setup.ts";

export async function setup(): Promise<SetupData> {
  return await loadSetup();
}

/**
 * create
 */
export default ({apiVersion, apiKey, traineeId}: SetupData) => {
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
