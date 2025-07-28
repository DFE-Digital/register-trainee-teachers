import { client } from "../client.ts";
import { setup as loadSetup, SetupData } from "../setup.ts";

export function setup(): SetupData {
  return loadSetup();
}

/**
 * DELETE /api/{apiVersion}/trainees/{traineeId}/degrees/{degreeId}
 */
export default ({apiVersion, apiKey, traineeId, degreeId}: SetupData) => {
  return client.deleteApiApiVersionTraineesTraineeIdDegreesDegreeId(
    apiVersion,
    traineeId,
    degreeId,
    {
      headers: { "Authorization": `Bearer ${apiKey}`}
    }
  );
}
