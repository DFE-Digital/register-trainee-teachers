import { client } from "../client.ts";
import { setup as loadSetup, SetupData } from "../setup.ts"

export async function setup(): Promise<SetupData> {
  return await loadSetup();
}

/**
 * show
 */
export default async ({apiVersion, apiKey, traineeId}:SetupData) => {
  return client.getApiApiVersionTraineesTraineeId(
    apiVersion,
    traineeId,
    {
      headers: { "Authorization": `Bearer ${apiKey}`}
    }
  );
}
