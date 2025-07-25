import secrets from "k6/secrets";

export interface SetupData {
  apiVersion: string,
  apiKey: string,
  traineeId?: string,
  degreeId?: string,
  placementId?: string
}

export async function setup(): Promise<SetupData> {
  const apiVersion  = "v2025.0-rc"
  const apiKey      = __ENV.auth_token || await secrets.get("apiKey");
  const traineeId   = await secrets.get("traineeId");
  const degreeId    = await secrets.get("degreeId");
  const placementId = await secrets.get("placementId");

  return {
    apiVersion,
    apiKey,
    traineeId,
    degreeId,
    placementId
  }
}
