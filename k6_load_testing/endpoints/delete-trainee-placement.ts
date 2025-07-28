import client from "../client.ts";
import { setup as loadSetup, SetupData } from "../setup.ts";

export function setup(): SetupData {
  return loadSetup();
}

/**
 * DELETE /api/{apiVersion}/trainees/{traineeId}/placements/{placementId}
 */
export default ({apiVersion, apiKey, traineeId, placementId}: SetupData) => {
  return client.deleteApiApiVersionTraineesTraineeIdPlacementsPlacementId(
    apiVersion,
    traineeId,
    placementId,
    {
      headers: { "Authorization": `Bearer ${apiKey}`}
    }
  );
}
