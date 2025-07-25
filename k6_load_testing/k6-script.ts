import getTrainees from "./endpoints/get-trainees.ts";
import postTrainees from "./endpoints/post-trainees.ts";
import getTrainee from "./endpoints/get-trainee.ts";
import putTrainee from "./endpoints/put-trainee.ts";
import postTraineeDefer from "./endpoints/post-trainee-defer.ts";
import getTraineeDegrees from "./endpoints/get-trainee-degrees.ts";
import postTraineeDegrees from "./endpoints/post-trainee-degrees.ts";
import getTraineeDegree from "./endpoints/get-trainee-degree.ts";
import putTraineeDegree from "./endpoints/put-trainee-degree.ts";
import deleteTraineeDegree from "./endpoints/delete-trainee-degree.ts";
import postTraineePlacements from "./endpoints/post-trainee-placements.ts";
import getTraineePlacement from "./endpoints/get-trainee-placement.ts";
import getTraineePlacements from "./endpoints/get-trainee-placements.ts";
import putTraineePlacement from "./endpoints/put-trainee-placement.ts";
import deleteTraineePlacement from "./endpoints/delete-trainee-placement.ts";
import postTraineeWithdraw from "./endpoints/post-trainee-withdraw.ts";

import { setup as loadSecrets, SetupData } from "./setup.ts";


export async function setup() {
  return await loadSecrets();
}

export default (data: SetupData) => {
  getTrainees(data);

  data.traineeId = postTrainees(data).response.json().data.trainee_id;

  getTrainee(data);

  putTrainee(data);

  postTraineeDefer(data);

  getTraineeDegrees(data);

  data.degreeId = postTraineeDegrees(data).response.json().data.degree_id;

  getTraineeDegree(data);

  putTraineeDegree(data);

  deleteTraineeDegree(data);

  data.placementId = postTraineePlacements(data).response.json().data.placement_id;

  getTraineePlacement(data)

  getTraineePlacements(data)

  putTraineePlacement(data);

  deleteTraineePlacement(data);

  postTraineeWithdraw(data);
}
