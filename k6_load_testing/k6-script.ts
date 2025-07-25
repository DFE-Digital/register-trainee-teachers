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

// export const options = {
//   vus: 10,
//   duration: '30s',
// };

export default () => {
  getTrainees().then(() => {
    postTrainees().then(async (traineeId) => {
      await getTrainee(traineeId);
      await putTrainee(traineeId);
      await postTraineeDefer(traineeId);
      await getTraineeDegrees(traineeId);

      postTraineeDegrees(traineeId).then(async (degreeId) => {
        await getTraineeDegree(traineeId, degreeId);
        await putTraineeDegree(traineeId, degreeId);
        await deleteTraineeDegree(traineeId, degreeId);

        postTraineePlacements(traineeId).then(async (placementId) => {
          await getTraineePlacement(traineeId, placementId)
          await getTraineePlacements(traineeId)
          await putTraineePlacement(traineeId, placementId);
          await deleteTraineePlacement(traineeId, placementId);
          await postTraineeWithdraw(traineeId);
        });
      });
    });
  });
}
