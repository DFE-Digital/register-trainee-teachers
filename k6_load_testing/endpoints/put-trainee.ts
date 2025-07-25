import { client } from "../client.ts";
import { setup as loadSetup, SetupData } from "../setup.ts";

export async function setup(): Promise<SetupData> {
  return await loadSetup();
}

/**
 * update
 */
export default ({apiVersion, apiKey, traineeId}: SetupData) => {
  const putApiApiVersionTraineesTraineeIdBody = {
    data: {
      first_names: "Alice",
    },
  };

  return client.putApiApiVersionTraineesTraineeId(
    apiVersion,
    traineeId,
    putApiApiVersionTraineesTraineeIdBody,
    {
      headers: { "Authorization": `Bearer ${apiKey}`}
    }
  );
}
