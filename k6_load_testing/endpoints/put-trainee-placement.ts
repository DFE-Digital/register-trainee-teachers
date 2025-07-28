import { client } from "../client.ts";
import { setup as loadSetup, SetupData } from "../setup.ts";

export async function setup(): Promise<SetupData> {
  return await loadSetup();
}

/**
 * PUT /api/{apiVersion}/trainees/{traineeId}/placements/{placementId}
 */
export default ({apiVersion, apiKey, traineeId, placementId}: SetupData) => {
  const putApiApiVersionTraineesTraineeIdPlacementsPlacementIdBody = {
    data: {
      urn: "100000",
    },
  };

  return client.putApiApiVersionTraineesTraineeIdPlacementsPlacementId(
      apiVersion,
      traineeId,
      placementId,
      putApiApiVersionTraineesTraineeIdPlacementsPlacementIdBody,
      {
        headers: { "Authorization": `Bearer ${apiKey}`}
      }
    );
}
