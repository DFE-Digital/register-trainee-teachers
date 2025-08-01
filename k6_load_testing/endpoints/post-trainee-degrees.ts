import client from "../client.ts";
import { setup as loadSetup, SetupData } from "../setup.ts";

export function setup(): Promise<SetupData> {
  return loadSetup();
}

/**
 * POST /api/{apiVersion}/trainees/{traineeId}/degrees
 */
export default ({apiVersion, apiKey, traineeId}: SetupData) => {
  const postApiApiVersionTraineesTraineeIdDegreesBody = {
    data: {
      grade: "02", subject: "100485", institution: "0117", uk_degree: "065", graduation_year: "2003"
    },
  };

  return client.postApiApiVersionTraineesTraineeIdDegrees(
    apiVersion,
    traineeId,
    postApiApiVersionTraineesTraineeIdDegreesBody,
    {
      headers: { "Authorization": `Bearer ${apiKey}`}
    }
  );
}
