import { RegisterAPIClient } from "./registerAPI.ts";

const baseUrl = "<BASE_URL>";
const registerAPIClient = new RegisterAPIClient({ baseUrl });

export default function () {
  let apiVersion,
    postApiApiVersionTraineesBody,
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
  apiVersion = "underneath";

  const getApiApiVersionInfoResponseData =
    registerAPIClient.getApiApiVersionInfo(apiVersion);

  /**
   * index
   */
  apiVersion = "questioningly";

  const getApiApiVersionTraineesResponseData =
    registerAPIClient.getApiApiVersionTrainees(apiVersion);

  /**
   * create
   */
  apiVersion = "forenenst";
  postApiApiVersionTraineesBody = {
    data: {
      first_names: "decongestant",
      middle_names: "searchingly",
      last_name: "yowza",
      date_of_birth: "chapel",
      sex: "crossly",
      email: "what",
      trn: "qua",
      training_route: "daily",
      itt_start_date: "piglet",
      itt_end_date: "who",
      diversity_disclosure: "completion",
      course_subject_one: "but",
      study_mode: "put",
      nationality: "scar",
      itt_aim: "encode",
      itt_qualification_aim: "male",
      course_year: "impeccable",
      course_age_range: "attribute",
      fund_code: "closely",
      funding_method: "physically",
      hesa_id: "boldly",
      previous_last_name: "aftermath",
      disability1: "um",
      disability2: "advancement",
      degrees_attributes: [],
      placements_attributes: [],
      provider_trainee_id: "whistle",
      pg_apprenticeship_start_date: "whose",
      lead_partner_ukprn: "object",
      employing_school_urn: "gah",
      lead_partner_urn: "outnumber",
      course_subject_two: "broadly",
      course_subject_three: "paltry",
      ethnicity: "decongestant",
      trainee_start_date: "loyally",
      application_id: 967141776437295,
    },
  };

  const postApiApiVersionTraineesResponseData =
    registerAPIClient.postApiApiVersionTrainees(
      apiVersion,
      postApiApiVersionTraineesBody,
    );

  /**
   * show
   */
  apiVersion = "supposing";
  traineeId = "penalise";

  const getApiApiVersionTraineesTraineeIdResponseData =
    registerAPIClient.getApiApiVersionTraineesTraineeId(apiVersion, traineeId);

  /**
   * update
   */
  apiVersion = "debit";
  traineeId = "lovely";
  putApiApiVersionTraineesTraineeIdBody = {
    data: {
      first_names: "badly",
      provider_trainee_id: "underneath",
      itt_start_date: "afore",
      nationality: "deform",
      course_age_range: "gosh",
      lead_partner_urn: "feather",
      employing_school_urn: "manipulate",
      ethnicity: "store",
      training_route: "triumphantly",
      disability1: "pish",
      disability2: "uh-huh",
      course_subject_one: "flood",
      course_subject_two: "if",
      course_subject_three: "ah",
      study_mode: "meh",
    },
  };

  const putApiApiVersionTraineesTraineeIdResponseData =
    registerAPIClient.putApiApiVersionTraineesTraineeId(
      apiVersion,
      traineeId,
      putApiApiVersionTraineesTraineeIdBody,
    );

  /**
   * create
   */
  apiVersion = "through";
  traineeId = "stigmatize";
  postApiApiVersionTraineesTraineeIdDeferBody = {
    data: {
      defer_date: "except",
    },
  };

  const postApiApiVersionTraineesTraineeIdDeferResponseData =
    registerAPIClient.postApiApiVersionTraineesTraineeIdDefer(
      apiVersion,
      traineeId,
      postApiApiVersionTraineesTraineeIdDeferBody,
    );

  /**
   * index
   */
  apiVersion = "modulo";
  traineeId = "frightfully";

  const getApiApiVersionTraineesTraineeIdDegreesResponseData =
    registerAPIClient.getApiApiVersionTraineesTraineeIdDegrees(
      apiVersion,
      traineeId,
    );

  /**
   * create
   */
  apiVersion = "shrill";
  traineeId = "buttery";
  postApiApiVersionTraineesTraineeIdDegreesBody = {
    data: {
      grade: "fast",
      subject: "slowly",
      institution: "yet",
      uk_degree: "insistent",
      graduation_year: "partially",
      country: "webbed",
      non_uk_degree: "qua",
    },
  };

  const postApiApiVersionTraineesTraineeIdDegreesResponseData =
    registerAPIClient.postApiApiVersionTraineesTraineeIdDegrees(
      apiVersion,
      traineeId,
      postApiApiVersionTraineesTraineeIdDegreesBody,
    );

  /**
   * destroy
   */
  apiVersion = "violin";
  traineeId = "needily";
  degreeId = "scoff";

  const deleteApiApiVersionTraineesTraineeIdDegreesDegreeIdResponseData =
    registerAPIClient.deleteApiApiVersionTraineesTraineeIdDegreesDegreeId(
      apiVersion,
      traineeId,
      degreeId,
    );

  /**
   * show
   */
  apiVersion = "orange";
  traineeId = "zowie";
  degreeId = "antique";

  const getApiApiVersionTraineesTraineeIdDegreesDegreeIdResponseData =
    registerAPIClient.getApiApiVersionTraineesTraineeIdDegreesDegreeId(
      apiVersion,
      traineeId,
      degreeId,
    );

  /**
   * update
   */
  apiVersion = "before";
  traineeId = "annex";
  degreeId = "hmph";
  putApiApiVersionTraineesTraineeIdDegreesDegreeIdBody = {
    data: {
      subject: "hm",
      uk_degree: "only",
      grade: "thoroughly",
      institution: "blah",
      graduation_year: "whoa",
      country: "well",
    },
  };

  const putApiApiVersionTraineesTraineeIdDegreesDegreeIdResponseData =
    registerAPIClient.putApiApiVersionTraineesTraineeIdDegreesDegreeId(
      apiVersion,
      traineeId,
      degreeId,
      putApiApiVersionTraineesTraineeIdDegreesDegreeIdBody,
    );

  /**
   * index
   */
  apiVersion = "wisely";
  traineeId = "messy";

  const getApiApiVersionTraineesTraineeIdPlacementsResponseData =
    registerAPIClient.getApiApiVersionTraineesTraineeIdPlacements(
      apiVersion,
      traineeId,
    );

  /**
   * create
   */
  apiVersion = "foretell";
  traineeId = "accompanist";
  postApiApiVersionTraineesTraineeIdPlacementsBody = {
    data: {
      urn: "fiercely",
      name: "underneath",
      postcode: "unto",
    },
  };

  const postApiApiVersionTraineesTraineeIdPlacementsResponseData =
    registerAPIClient.postApiApiVersionTraineesTraineeIdPlacements(
      apiVersion,
      traineeId,
      postApiApiVersionTraineesTraineeIdPlacementsBody,
    );

  /**
   * destroy
   */
  apiVersion = "whereas";
  traineeId = "oof";
  placementId = "construe";

  const deleteApiApiVersionTraineesTraineeIdPlacementsPlacementIdResponseData =
    registerAPIClient.deleteApiApiVersionTraineesTraineeIdPlacementsPlacementId(
      apiVersion,
      traineeId,
      placementId,
    );

  /**
   * show
   */
  apiVersion = "though";
  traineeId = "pointless";
  placementId = "phooey";

  const getApiApiVersionTraineesTraineeIdPlacementsPlacementIdResponseData =
    registerAPIClient.getApiApiVersionTraineesTraineeIdPlacementsPlacementId(
      apiVersion,
      traineeId,
      placementId,
    );

  /**
   * update
   */
  apiVersion = "glider";
  traineeId = "going";
  placementId = "corral";
  putApiApiVersionTraineesTraineeIdPlacementsPlacementIdBody = {
    data: {
      urn: "who",
      name: "what",
      postcode: "hmph",
    },
  };

  const putApiApiVersionTraineesTraineeIdPlacementsPlacementIdResponseData =
    registerAPIClient.putApiApiVersionTraineesTraineeIdPlacementsPlacementId(
      apiVersion,
      traineeId,
      placementId,
      putApiApiVersionTraineesTraineeIdPlacementsPlacementIdBody,
    );

  /**
   * create
   */
  apiVersion = "nor";
  traineeId = "valiantly";
  postApiApiVersionTraineesTraineeIdRecommendForQtsBody = {
    data: {
      qts_standards_met_date: "scheme",
    },
  };

  const postApiApiVersionTraineesTraineeIdRecommendForQtsResponseData =
    registerAPIClient.postApiApiVersionTraineesTraineeIdRecommendForQts(
      apiVersion,
      traineeId,
      postApiApiVersionTraineesTraineeIdRecommendForQtsBody,
    );

  /**
   * create
   */
  apiVersion = "gah";
  traineeId = "cloudy";
  postApiApiVersionTraineesTraineeIdWithdrawBody = {
    data: {
      reasons: [],
      withdraw_date: "pro",
      trigger: "stump",
      future_interest: "scuttle",
    },
  };

  const postApiApiVersionTraineesTraineeIdWithdrawResponseData =
    registerAPIClient.postApiApiVersionTraineesTraineeIdWithdraw(
      apiVersion,
      traineeId,
      postApiApiVersionTraineesTraineeIdWithdrawBody,
    );
}
