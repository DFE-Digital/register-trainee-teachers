import secrets from "./secrets.ts"

const apiVersion  = "v2025.0-rc"

export interface SetupData {
  apiVersion: string,
  apiKey: string,
  traineeId?: string,
  degreeId?: string,
  placementId?: string,
  academicCycle?: string,
}

export function setup(): SetupData {
  return { apiVersion, ...secrets };
}
