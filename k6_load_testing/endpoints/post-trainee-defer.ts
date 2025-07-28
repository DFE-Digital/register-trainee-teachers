import { client } from "../client.ts";
import { setup as loadSetup, SetupData } from "../setup.ts";

export function setup(): Promise<SetupData> {
  return loadSetup();
}

/**
 * POST /api/{apiVersion}/trainees/{traineeId}/defer
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
