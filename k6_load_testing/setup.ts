import secrets from "./secrets.ts"

const apiVersion  = "v2025.0-rc"

export interface SetupData {
  apiVersion: string,
  apiKey: string,
  traineeId?: string,
  degreeId?: string,
  placementId?: string
}

export function setup() {
  let loadSecrets: SetupData = { apiVersion: apiVersion, apiKey: __ENV.AUTH_TOKEN };

  if ( !loadSecrets.apiKey ) {
    loadSecrets = { ...loadSecrets, ...secrets };
  }

  return loadSecrets;
}
