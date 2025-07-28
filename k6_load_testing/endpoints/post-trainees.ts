import { client } from "../client.ts";
import { setup as loadSetup, SetupData } from "../setup.ts";
import { randomString } from 'https://jslib.k6.io/k6-utils/1.2.0/index.js';

export function setup(): SetupData {
  return loadSetup();
}

/**
 * POST /api/{apiVersion}/trainees
 */
export default ({apiVersion, apiKey}: SetupData) => {
  const postApiApiVersionTraineesBody = {
    data: {
      first_names: "John",
      last_name: randomString(8),
      previous_last_name: "Smith",
      date_of_birth: "1990-01-01",
      sex: "10",
      email: "john.doe@example.com",
      nationality: "GB",
      training_route: "11",
      itt_start_date: "2024-08-01",
      itt_end_date: "2025-08-01",
      trainee_start_date: "2024-08-01",
      course_subject_one: "100346",
      study_mode: "63",
      disability1: "58",
      disability2: "57",
      degrees_attributes: [
        {
          grade: "02",
          subject: "100485",
          institution: "0117",
          uk_degree: "083",
          graduation_year: "2003"
        }
      ],
      placements_attributes: [
        {
          name: "Placement",
          urn: "900020"
        }
      ],
      itt_aim: "202",
      itt_qualification_aim: "001",
      course_year: "2012",
      course_age_range: "13918",
      fund_code: "2",
      funding_method: "6",
      hesa_id: "0310261553101",
      provider_trainee_id: "99157234/2/01",
      pg_apprenticeship_start_date: "2024-03-11"
    }
  };

  return client.postApiApiVersionTrainees(
    apiVersion,
    postApiApiVersionTraineesBody,
    {
      headers: { "Authorization": `Bearer ${apiKey}`}
    }
  );
}
