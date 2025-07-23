import secrets from "k6/secrets";
import { randomString } from 'https://jslib.k6.io/k6-utils/1.2.0/index.js';

import { RegisterAPIClient } from "./registerAPI.ts";

const baseUrl           = "https://staging.register-trainee-teachers.service.gov.uk";
const registerAPIClient = new RegisterAPIClient({ baseUrl });

// export const options = {
//   vus: 10,
//   duration: '30s',
// };

export default async () => {
  const apiVersion = "v2025.0-rc"
  const apiKey     = __ENV.AUTH_TOKEN || await secrets.get("apiKey");

  let postApiApiVersionTraineesBody,
  traineeId,
  putApiApiVersionTraineesTraineeIdBody,
  postApiApiVersionTraineesTraineeIdDeferBody,
  postApiApiVersionTraineesTraineeIdDegreesBody,
  degreeId,
  putApiApiVersionTraineesTraineeIdDegreesDegreeIdBody,
  postApiApiVersionTraineesTraineeIdPlacementsBody,
  placementId,
  putApiApiVersionTraineesTraineeIdPlacementsPlacementIdBody,
  postApiApiVersionTraineesTraineeIdRecommendForQtsBody,
  postApiApiVersionTraineesTraineeIdWithdrawBody;

  /**
   * show
   */
  const getApiApiVersionInfoResponseData =
    registerAPIClient.getApiApiVersionInfo(apiVersion, { headers: { "Authorization": `Bearer ${apiKey}` }});

  /**
   * index
   */
  const getApiApiVersionTraineesResponseData =
    registerAPIClient.getApiApiVersionTrainees(
      apiVersion,
      undefined,
      {
        headers: { "Authorization": `Bearer ${apiKey}`}
      }
    );

  /**
   * create
   */
  postApiApiVersionTraineesBody = {
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
      degrees_attributes: [{grade: "02", subject: "100485", institution: "0117", uk_degree: "083", graduation_year: "2003"}],
      placements_attributes: [{name: "Placement", urn: "900020"}],
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

  const postApiApiVersionTraineesResponseData =
    registerAPIClient.postApiApiVersionTrainees(
      apiVersion,
      postApiApiVersionTraineesBody,
      {
        headers: { "Authorization": `Bearer ${apiKey}`}
      }
    );

  /**
   * show
   */
  traineeId = postApiApiVersionTraineesResponseData.response.json().data.trainee_id

  const getApiApiVersionTraineesTraineeIdResponseData =
    registerAPIClient.getApiApiVersionTraineesTraineeId(
      apiVersion,
      traineeId,
      {
        headers: { "Authorization": `Bearer ${apiKey}`}
      }
    );

  /**
   * update
   */
  putApiApiVersionTraineesTraineeIdBody = {
    data: {
      first_names: "Alice",
    },
  };

  const putApiApiVersionTraineesTraineeIdResponseData =
    registerAPIClient.putApiApiVersionTraineesTraineeId(
      apiVersion,
      traineeId,
      putApiApiVersionTraineesTraineeIdBody,
      {
        headers: { "Authorization": `Bearer ${apiKey}`}
      }
    );

  /**
   * create
   */
  postApiApiVersionTraineesTraineeIdDeferBody = {
    data: {
      defer_date: "2025-07-21",
    },
  };

  const postApiApiVersionTraineesTraineeIdDeferResponseData =
    registerAPIClient.postApiApiVersionTraineesTraineeIdDefer(
      apiVersion,
      traineeId,
      postApiApiVersionTraineesTraineeIdDeferBody,
      {
        headers: { "Authorization": `Bearer ${apiKey}`}
      }
    );

  /**
   * index
   */
  const getApiApiVersionTraineesTraineeIdDegreesResponseData =
    registerAPIClient.getApiApiVersionTraineesTraineeIdDegrees(
      apiVersion,
      traineeId,
      {
        headers: { "Authorization": `Bearer ${apiKey}`}
      }
    );

  /**
   * create
   */
  postApiApiVersionTraineesTraineeIdDegreesBody = {
    data: {
      grade: "02", subject: "100485", institution: "0117", uk_degree: "065", graduation_year: "2003"
    },
  };

  const postApiApiVersionTraineesTraineeIdDegreesResponse =
    registerAPIClient.postApiApiVersionTraineesTraineeIdDegrees(
      apiVersion,
      traineeId,
      postApiApiVersionTraineesTraineeIdDegreesBody,
      {
        headers: { "Authorization": `Bearer ${apiKey}`}
      }
    );

  /**
   * show
   */
  degreeId = postApiApiVersionTraineesTraineeIdDegreesResponse.response.json().data.degree_id;

  const getApiApiVersionTraineesTraineeIdDegreesDegreeIdResponseData =
    registerAPIClient.getApiApiVersionTraineesTraineeIdDegreesDegreeId(
      apiVersion,
      traineeId,
      degreeId,
      {
        headers: { "Authorization": `Bearer ${apiKey}`}
      }
    );

  /**
   * update
   */
  putApiApiVersionTraineesTraineeIdDegreesDegreeIdBody = {
    data: {
      grade: "02",
      subject: "100425",
      institution: "0117",
      uk_degree: "002",
      graduation_year: "2015-01-01",
      country: "XF",
    },
  };

  const putApiApiVersionTraineesTraineeIdDegreesDegreeIdResponseData =
  registerAPIClient.putApiApiVersionTraineesTraineeIdDegreesDegreeId(
    apiVersion,
    traineeId,
    degreeId,
    putApiApiVersionTraineesTraineeIdDegreesDegreeIdBody,
    {
      headers: { "Authorization": `Bearer ${apiKey}`}
    }
  );

  /**
   * destroy
   */
  const deleteApiApiVersionTraineesTraineeIdDegreesDegreeIdResponseData =
  registerAPIClient.deleteApiApiVersionTraineesTraineeIdDegreesDegreeId(
    apiVersion,
    traineeId,
    degreeId,
    {
      headers: { "Authorization": `Bearer ${apiKey}`}
    }
  );

  /**
   * index
   */
  const getApiApiVersionTraineesTraineeIdPlacementsResponseData =
    registerAPIClient.getApiApiVersionTraineesTraineeIdPlacements(
      apiVersion,
      traineeId,
      {
        headers: { "Authorization": `Bearer ${apiKey}`}
      }
    );

  /**
   * create
   */
  postApiApiVersionTraineesTraineeIdPlacementsBody = {
    data: {
      urn: "151631",
    },
  };
  //
  const postApiApiVersionTraineesTraineeIdPlacementsResponseData =
    registerAPIClient.postApiApiVersionTraineesTraineeIdPlacements(
      apiVersion,
      traineeId,
      postApiApiVersionTraineesTraineeIdPlacementsBody,
      {
        headers: { "Authorization": `Bearer ${apiKey}`}
      }
    );

  /**
   * show
   */
  placementId = postApiApiVersionTraineesTraineeIdPlacementsResponseData.response.json().data.placement_id;

  const getApiApiVersionTraineesTraineeIdPlacementsPlacementIdResponseData =
  registerAPIClient.getApiApiVersionTraineesTraineeIdPlacementsPlacementId(
    apiVersion,
    traineeId,
    placementId,
    {
      headers: { "Authorization": `Bearer ${apiKey}`}
    }
  );

  /**
   * update
   */
  putApiApiVersionTraineesTraineeIdPlacementsPlacementIdBody = {
    data: {
      urn: "100000",
    },
  };

  const putApiApiVersionTraineesTraineeIdPlacementsPlacementIdResponseData =
    registerAPIClient.putApiApiVersionTraineesTraineeIdPlacementsPlacementId(
      apiVersion,
      traineeId,
      placementId,
      putApiApiVersionTraineesTraineeIdPlacementsPlacementIdBody,
      {
        headers: { "Authorization": `Bearer ${apiKey}`}
      }
    );

  /**
   * destroy
   */
  const deleteApiApiVersionTraineesTraineeIdPlacementsPlacementIdResponseData =
  registerAPIClient.deleteApiApiVersionTraineesTraineeIdPlacementsPlacementId(
    apiVersion,
    traineeId,
    placementId,
    {
      headers: { "Authorization": `Bearer ${apiKey}`}
    }
  );


  /**
   * create
   */
  postApiApiVersionTraineesTraineeIdWithdrawBody = {
    data: {
      reasons: ["record_added_in_error"],
      withdraw_date: "2025-07-23",
      trigger: "provider",
      future_interest: "no"
    }
  };

  const postApiApiVersionTraineesTraineeIdWithdrawResponseData =
    registerAPIClient.postApiApiVersionTraineesTraineeIdWithdraw(
      apiVersion,
      traineeId,
      postApiApiVersionTraineesTraineeIdWithdrawBody,
      {
        headers: { "Authorization": `Bearer ${apiKey}`}
      }
    );
}
