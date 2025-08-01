import client from "../client.ts";
import { setup as loadSetup, SetupData } from "../setup.ts";

export function setup(): SetupData {
  return loadSetup();
}

/**
 * GET /api/{apiVersion}/trainees/{traineeId}/degrees
 */
export default ({apiVersion, apiKey, traineeId}: SetupData) => {
  return client.getApiApiVersionTraineesTraineeIdDegrees(
    apiVersion,
    traineeId,
    {
      headers: { "Authorization": `Bearer ${apiKey}`}
    }
  );
}
