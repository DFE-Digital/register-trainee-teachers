import { client } from "../client.ts";
import { setup as loadSetup, SetupData } from "../setup.ts";

export function setup(): SetupData {
  return loadSetup();
}

/**
 * GET /api/{apiVersion}/trainees/{traineeId}/placements
 */
export default ({apiVersion, apiKey, traineeId}: SetupData) => {
  return client.getApiApiVersionTraineesTraineeIdPlacements(
    apiVersion,
    traineeId,
    {
      headers: { "Authorization": `Bearer ${apiKey}`}
    }
  );
}
