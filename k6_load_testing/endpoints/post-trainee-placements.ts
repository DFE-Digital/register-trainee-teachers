import { client } from "../client.ts";
import { setup as loadSetup, SetupData } from "../setup.ts";

export async function setup(): Promise<SetupData> {
  return await loadSetup();
}

/**
 * POST /api/{apiVersion}/trainees/{traineeId}/placements
 */
export default ({apiVersion, apiKey, traineeId}: SetupData) => {
  const postApiApiVersionTraineesTraineeIdPlacementsBody = {
    data: {
      urn: "151631",
    },
  };

  return client.postApiApiVersionTraineesTraineeIdPlacements(
    apiVersion,
    traineeId,
    postApiApiVersionTraineesTraineeIdPlacementsBody,
    {
      headers: { "Authorization": `Bearer ${apiKey}`}
    }
  );
}
