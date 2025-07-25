import { client } from "../client.ts";
import { setup as loadSetup, SetupData } from "../setup.ts";

export async function setup(): Promise<SetupData> {
  return await loadSetup();
}

/**
 * index
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
