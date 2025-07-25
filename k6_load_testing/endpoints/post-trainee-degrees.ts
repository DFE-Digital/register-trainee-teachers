import secrets from "k6/secrets";
import { client } from "../client.ts";

/**
 * create
 */
export default async (traineeId?: string): Promise<string> => {
  const apiVersion = "v2025.0-rc"
  const apiKey     = __ENV.AUTH_TOKEN || await secrets.get("apiKey");

  traineeId ||= await secrets.get("traineeId");

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
  ).response.json().data.degree_id;
}
