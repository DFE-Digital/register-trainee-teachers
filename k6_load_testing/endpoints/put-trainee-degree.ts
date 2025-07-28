import { client } from "../client.ts";
import { setup as loadSetup, SetupData } from "../setup.ts";

export function setup(): SetupData {
  return loadSetup();
}

/**
 * PUT /api/{apiVersion}/trainees/{traineeId}/degrees/{degreeId}
 */
export default ({apiVersion, apiKey, traineeId, degreeId}: SetupData) => {
  const putApiApiVersionTraineesTraineeIdDegreesDegreeIdBody = {
    data: {
      grade: "02",
      subject: "100425",
      institution: "0117",
      uk_degree: "002",
      graduation_year: "2015-01-01",
      country: "XF",
    },
  };

  return client.putApiApiVersionTraineesTraineeIdDegreesDegreeId(
    apiVersion,
    traineeId,
    degreeId,
    putApiApiVersionTraineesTraineeIdDegreesDegreeIdBody,
    {
      headers: { "Authorization": `Bearer ${apiKey}`}
    }
  );
}
