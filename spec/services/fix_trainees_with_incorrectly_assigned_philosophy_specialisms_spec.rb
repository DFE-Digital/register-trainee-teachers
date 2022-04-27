# frozen_string_literal: true

require "rails_helper"

describe FixTraineesWithIncorrectlyAssignedPhilosophySpecialisms do
  let!(:dttp_trainee) { create(:dttp_trainee, trainee: trainee, placement_assignments: [placement_assignment]) }
  let(:placement_assignment) { create(:dttp_placement_assignment, response: response) }

  describe "when philosophy is the first subject" do
    let!(:trainee) { create(:trainee, :trn_received, course_subject_one: "philosophy", created_from_dttp: true) }
    let(:response) {
      create(:api_placement_assignment,
             _dfe_ittsubject1id_value: Dttp::CodeSets::CourseSubjects::MAPPING[::CourseSubjects::RELIGIOUS_STUDIES][:entity_id])
    }

    it "reassigns philosophy courses to religious education if they have a religious education code in dttp response" do
      subject.call
      expect(trainee.reload.course_subject_one).to eq(CourseSubjects::RELIGIOUS_STUDIES)
    end

    describe "when philosophy is the correct subject specialism" do
      let(:response) {
        create(:api_placement_assignment,
               _dfe_ittsubject1id_value: Dttp::CodeSets::CourseSubjects::MAPPING[::CourseSubjects::PHILOSOPHY][:entity_id])
      }

      it "does not reassign the subject to religious studies" do
        subject.call
        expect(trainee.reload.course_subject_one).to eq(CourseSubjects::PHILOSOPHY)
      end
    end
  end

  describe "when philosophy is the second subject" do
    let!(:trainee) { create(:trainee, :trn_received, course_subject_two: "philosophy", created_from_dttp: true) }
    let(:response) {
      create(:api_placement_assignment,
             _dfe_ittsubject2id_value: Dttp::CodeSets::CourseSubjects::MAPPING[::CourseSubjects::RELIGIOUS_STUDIES][:entity_id])
    }

    it "reassigns philosophy courses to religious education if they have a religious education code in dttp response" do
      subject.call
      expect(trainee.reload.course_subject_two).to eq(CourseSubjects::RELIGIOUS_STUDIES)
    end
  end

  describe "when philosophy is the third subject" do
    let!(:trainee) { create(:trainee, :trn_received, course_subject_three: "philosophy", created_from_dttp: true) }
    let(:response) {
      create(:api_placement_assignment,
             _dfe_ittsubject3id_value: Dttp::CodeSets::CourseSubjects::MAPPING[::CourseSubjects::RELIGIOUS_STUDIES][:entity_id])
    }

    it "reassigns philosophy courses to religious education if they have a religious education code in dttp response" do
      subject.call
      expect(trainee.reload.course_subject_three).to eq(CourseSubjects::RELIGIOUS_STUDIES)
    end
  end
end
