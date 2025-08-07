import { RegisterAPIClient } from "./registerAPI.ts";

const baseUrl = "https://staging.register-trainee-teachers.service.gov.uk";
const client  = new RegisterAPIClient({baseUrl: baseUrl})

export default client;
