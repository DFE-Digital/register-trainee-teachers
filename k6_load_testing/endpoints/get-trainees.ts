import client from "../client.ts";
import { setup as loadSetup, SetupData } from "../setup.ts";

export function setup(): SetupData {
  return loadSetup();
}

/**
 * GET /api/{apiVersion}/trainees
 */
export default ({apiVersion, apiKey, academicCycle}: SetupData) => {
  return client.getApiApiVersionTrainees(
    apiVersion,
    {
      academic_cycle: academicCycle,
    },
    {
      headers: { "Authorization": `Bearer ${apiKey}`}
    }
  );
}
