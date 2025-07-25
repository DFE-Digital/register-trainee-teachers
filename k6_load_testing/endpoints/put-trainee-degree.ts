import secrets from "k6/secrets";
import { client } from "../client.ts";

/**
 * update
 */
export default async (traineeId?: string, degreeId?: string) => {
  const apiVersion = "v2025.0-rc"
  const apiKey     = __ENV.AUTH_TOKEN || await secrets.get("apiKey");

  traineeId ||= await secrets.get("traineeId");
  degreeId  ||= await secrets.get("degreeId");

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
