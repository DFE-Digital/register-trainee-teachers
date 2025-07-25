import { client } from "../client.ts";
import { setup as loadSetup, SetupData } from "../setup.ts";

export async function setup(): Promise<SetupData> {
  return await loadSetup();
}

/**
 * index
 */
export default ({apiVersion, apiKey}: {apiVersion: string; apiKey: string}) => {
  return client.getApiApiVersionTrainees(
    apiVersion,
    undefined,
    {
      headers: { "Authorization": `Bearer ${apiKey}`}
    }
  );
}
