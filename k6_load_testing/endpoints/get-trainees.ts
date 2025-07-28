import { client } from "../client.ts";
import { setup as loadSetup, SetupData } from "../setup.ts";

export function setup(): SetupData {
  return loadSetup();
}

/**
 * GET /api/{apiVersion}/trainees
 */
export default ({apiVersion, apiKey}: SetupData) => {
  return client.getApiApiVersionTrainees(
    apiVersion,
    undefined,
    {
      headers: { "Authorization": `Bearer ${apiKey}`}
    }
  );
}
