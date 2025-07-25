import secrets from "k6/secrets";
import { RegisterAPIClient } from "./registerAPI.ts";

const baseUrl           = "https://staging.register-trainee-teachers.service.gov.uk";

export const client = new RegisterAPIClient({baseUrl: baseUrl})
