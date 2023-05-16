# frozen_string_literal: true

require "rails_helper"

describe Reports::TraineeReport do
  let(:current_cycle) { create(:academic_cycle, :current) }
  let(:next_cycle) { create(:academic_cycle, next_cycle: true) }
  let(:trainee) { create(:trainee, :for_export, course_uuid: create(:course).uuid) }
  let(:degree) { subject.degree }
  let(:course) { subject.course }

  subject { described_class.new(trainee) }

  context "when there is a trainee" do
    it "has a valid factory" do
      expect(trainee).to be_valid
    end

    it "accepts a trainee" do
      expect(subject.trainee).to eq(trainee)
    end

    it "sets the correct degree" do
      expect(degree).to eq(trainee.degrees.first)
    end

    it "sets a funding manager" do
      expect(subject.funding_manager).to be_a(FundingManager)
    end

    it "sets the correct course" do
      expect(course).to eq(Course.find_by(uuid: trainee.course_uuid))
    end

    it "includes the register_id" do
      expect(subject.register_id).to eq(trainee.slug)
    end

    it "includes the trainee_url" do
      expect(subject.trainee_url).to end_with(trainee.slug)
    end

    it "includes the record_source" do
      expect(subject.record_source.downcase).to eq(trainee.derived_record_source.downcase)
    end

    it "includes the apply_id" do
      expect(subject.apply_id).to eq(trainee.apply_application&.apply_id)
    end

    it "includes the hesa_id" do
      expect(subject.hesa_id).to eq(trainee.hesa_id)
    end

    it "includes the provider_trainee_id" do
      expect(subject.provider_trainee_id).to eq(trainee.trainee_id)
    end

    it "includes the trn" do
      expect(subject.trn).to eq(trainee.trn)
    end

    it "includes the trainee_status" do
      expect(subject.trainee_status).to eq(StatusTag::View.new(trainee:).status)
    end

    it "includes the start_academic_year" do
      expect(subject.start_academic_year).to eq(trainee.start_academic_cycle&.label)
    end

    it "includes the end_academic_year" do
      expect(subject.end_academic_year).to eq(trainee.end_academic_cycle&.label)
    end

    it "includes the record_created_at" do
      expect(subject.record_created_at).to eq(trainee.created_at&.iso8601)
    end

    it "includes the register_record_last_changed_at" do
      expect(subject.register_record_last_changed_at).to eq(trainee.updated_at&.iso8601)
    end

    it "includes the hesa_record_last_changed_at" do
      expect(subject.hesa_record_last_changed_at).to eq(trainee.hesa_updated_at&.iso8601)
    end

    it "includes the submitted_for_trn_at" do
      expect(subject.submitted_for_trn_at).to eq(trainee.submitted_for_trn_at&.iso8601)
    end

    it "includes the provider_name" do
      expect(subject.provider_name).to eq(trainee.provider&.name)
    end

    it "includes the provider_id" do
      expect(subject.provider_id).to eq(trainee.provider&.code)
    end

    it "includes the first_names" do
      expect(subject.first_names).to eq(trainee.first_names)
    end

    it "includes the middle_names" do
      expect(subject.middle_names).to eq(trainee.middle_names)
    end

    it "includes the last_names" do
      expect(subject.last_names).to eq(trainee.last_name)
    end

    it "includes the date_of_birth" do
      expect(subject.date_of_birth).to eq(trainee.date_of_birth&.iso8601)
    end

    it "includes the sex" do
      expect(subject.sex).to eq(I18n.t("components.confirmation.personal_detail.sexes.#{trainee.sex}"))
    end

    it "includes the nationality" do
      expect(subject.nationality).to eq(trainee.nationalities.pluck(:name).map(&:titleize).join(", "))
    end

    it "includes the address_line_1" do
      expect(subject.address_line_1).to eq(trainee.address_line_one)
    end

    it "includes the address_line_2" do
      expect(subject.address_line_2).to eq(trainee.address_line_two)
    end

    it "includes the town_city" do
      expect(subject.town_city).to eq(trainee.town_city)
    end

    it "includes the postcode" do
      expect(subject.postcode).to eq(trainee.postcode)
    end

    it "includes the international_address" do
      expect(subject.international_address).to eq(Array(trainee.international_address.split(/[\r\n,]/)).join(", ").presence)
    end

    it "includes the email_address" do
      expect(subject.email_address).to eq(trainee.email)
    end

    it "includes the diversity_disclosure" do
      expect(subject.diversity_disclosure).to eq(trainee.diversity_disclosure == "diversity_disclosed" ? "TRUE" : "FALSE")
    end

    it "includes the ethnic_group" do
      expect(subject.ethnic_group).to eq(I18n.t("components.confirmation.diversity.ethnic_groups.#{trainee.ethnic_group.presence || 'not_provided_ethnic_group'}"))
    end

    it "includes the ethnic_background" do
      expect(subject.ethnic_background).to eq(trainee.ethnic_background)
    end

    it "includes the ethnic_background_additional" do
      expect(subject.ethnic_background_additional).to eq(trainee.additional_ethnic_background)
    end

    it "includes the disability_disclosure" do
      expect(subject.disability_disclosure).to eq("Has disabilities")
    end

    it "includes the disabilities" do
      expect(subject.disabilities).to start_with("disability ")
    end

    it "includes the number_of_degrees" do
      expect(subject.number_of_degrees).to eq(trainee.degrees.size)
    end

    it "includes the degree_1_uk_or_non_uk" do
      expect(subject.degree_1_uk_or_non_uk).to eq(degree.locale_code.gsub("_", "-").gsub("uk", "UK"))
    end

    it "includes the degree_1_awarding_institution" do
      expect(subject.degree_1_awarding_institution).to eq(degree.institution)
    end

    it "includes the degree_1_country" do
      expect(subject.degree_1_country).to eq(degree.country)
    end

    it "includes the degree_1_subject" do
      expect(subject.degree_1_subject).to eq(degree.subject)
    end

    it "includes the degree_1_type_uk" do
      expect(subject.degree_1_type_uk).to eq(degree.uk_degree)
    end

    it "includes the degree_1_type_non_uk" do
      expect(subject.degree_1_type_non_uk).to eq(degree.non_uk_degree)
    end

    it "includes the degree_1_grade" do
      expect(subject.degree_1_grade).to eq(degree.grade)
    end

    it "includes the degree_1_other_grade" do
      expect(subject.degree_1_other_grade).to eq(degree.other_grade)
    end

    it "includes the degree_1_graduation_year" do
      expect(subject.degree_1_graduation_year).to eq(degree.graduation_year)
    end

    it "includes the degrees" do
      expect(subject.degrees).to be_a(String)
    end

    it "includes the course_training_route" do
      expect(subject.course_training_route).to eq(I18n.t("activerecord.attributes.trainee.training_routes.#{trainee.training_route}"))
    end

    it "includes the course_qualification" do
      expect(subject.course_qualification).to eq(trainee.award_type)
    end

    it "includes the course_education_phase" do
      expect(subject.course_education_phase).to eq(trainee.course_education_phase&.upcase_first || course&.level&.capitalize)
    end

    it "includes the course_subject_category" do
      expect(subject.course_subject_category).to eq(SubjectSpecialism.find_by("lower(name) = ?", trainee.course_subject_one.downcase)&.allocation_subject&.name)
    end

    it "includes the course_itt_subject_1" do
      expect(subject.course_itt_subject_1).to eq(trainee.course_subject_one)
    end

    it "includes the course_itt_subject_2" do
      expect(subject.course_itt_subject_2).to eq(trainee.course_subject_two)
    end

    it "includes the course_itt_subject_3" do
      expect(subject.course_itt_subject_3).to eq(trainee.course_subject_three)
    end

    it "includes the course_minimum_age" do
      expect(subject.course_minimum_age).to eq(trainee.course_min_age)
    end

    it "includes the course_maximum_age" do
      expect(subject.course_maximum_age).to eq(trainee.course_max_age)
    end

    it "includes the course_full_or_part_time" do
      expect(subject.course_full_or_part_time).to eq(trainee.study_mode.humanize)
    end

    it "includes the course_level" do
      expect(subject.course_level).to eq(trainee.undergrad_route? ? "undergrad" : "postgrad")
    end

    it "includes the itt_start_date" do
      expect(subject.itt_start_date).to eq(trainee.itt_start_date&.iso8601)
    end

    it "includes the expected_end_date" do
      expect(subject.expected_end_date).to eq(trainee.itt_end_date&.iso8601)
    end

    it "includes the course_duration_in_years" do
      expect(subject.course_duration_in_years).to eq(trainee.course_duration_in_years)
    end

    it "includes the trainee_start_date" do
      expect(subject.trainee_start_date).to eq(trainee.trainee_start_date&.iso8601)
    end

    it "includes the lead_school_name" do
      expect(subject.lead_school_name).to eq(trainee.lead_school_not_applicable? ? I18n.t(:not_applicable) : trainee.lead_school&.name)
    end

    it "includes the lead_school_urn" do
      expect(subject.lead_school_urn).to eq(trainee.lead_school&.urn)
    end

    it "includes the employing_school_name" do
      expect(subject.employing_school_name).to eq(trainee.employing_school_not_applicable? ? I18n.t(:not_applicable) : trainee.employing_school&.name)
    end

    it "includes the employing_school_urn" do
      expect(subject.employing_school_urn).to eq(trainee.employing_school&.urn)
    end

    it "includes the training_initiative" do
      expect(subject.training_initiative).to eq(I18n.t("activerecord.attributes.trainee.training_initiatives.#{trainee.training_initiative}"))
    end

    it "includes the funding_method" do
      expect(subject.funding_method).to eq("bursary")
    end

    it "includes the funding_value" do
      expect(subject.funding_value).to eq(5000)
    end

    it "includes the bursary_tier" do
      expect(subject.bursary_tier).to eq("Tier 1")
    end

    context "when placement data is available" do
      let(:hesa_student) do
        create(
          :hesa_student,
          collection_reference: "C22053",
          hesa_id: trainee.hesa_id,
          first_names: trainee.first_names,
          last_name: trainee.last_name,
          degrees: degrees,
          placements: placements,
        )
      end

      let!(:schools) { create_list(:school, 4) }

      let(:degrees) do
        [{ "graduation_date" => "2019-06-13", "degree_type" => "051", "subject" => "100318", "institution" => "0012", "grade" => "02", "country" => nil }]
      end

      before do
        allow(Settings.hesa).to receive(:current_collection_reference).and_return("C22053")

        trainee.hesa_students << hesa_student
      end

      context "when there is only one placement" do
        let(:placements) do
          [{ "school_urn" => schools[0].urn }]
        end

        it "includes the placement_one with the urn value" do
          expect(subject.placement_one).to eq(schools[0].urn)
        end

        Trainees::CreateFromHesa::NOT_APPLICABLE_SCHOOL_URNS.each do |magic_urn|
          context "when it contains the magic URN #{magic_urn}" do
            let(:placements) do
              [{ "school_urn" => magic_urn }]
            end

            it "includes the placement_one with the special placement label" do
              expect(subject.placement_one).to eq(I18n.t("components.placement_detail.magic_urn.#{magic_urn}"))
            end
          end
        end
      end

      context "when there are two placements" do
        let(:placements) do
          [{ "school_urn" => schools[0].urn }, { "school_urn" => schools[1].urn }]
        end

        it "includes the placement_two with the urn value" do
          expect(subject.placement_two).to eq(schools[1].urn)
        end
      end

      context "when there are over two placements" do
        let(:placements) do
          [{ "school_urn" => schools[0].urn }, { "school_urn" => schools[1].urn }, { "school_urn" => schools[2].urn }, { "school_urn" => schools[3].urn }]
        end

        it "includes the other_placements with the urn values comma separated" do
          expect(subject.other_placements).to eq("#{schools[2].urn}, #{schools[3].urn}")
        end
      end
    end

    it "includes the placement_one" do
      expect(subject.placement_one).to eq("")
    end

    it "includes the placement_two" do
      expect(subject.placement_two).to eq("")
    end

    it "includes the other_placements" do
      expect(subject.other_placements).to eq("")
    end

    it "includes the award_standards_met_date" do
      expect(subject.award_standards_met_date).to eq(trainee.outcome_date&.iso8601)
    end

    it "includes the award_given_at" do
      expect(subject.award_given_at).to eq(trainee.awarded_at&.iso8601)
    end

    it "includes the defer_date" do
      expect(subject.defer_date).to eq(trainee.defer_date&.iso8601)
    end

    it "includes the return_from_deferral_date" do
      expect(subject.return_from_deferral_date).to eq(trainee.reinstate_date&.iso8601)
    end

    it "includes the withdraw_date" do
      expect(subject.withdraw_date).to eq(trainee.withdraw_date&.to_date&.iso8601)
    end

    it "includes the withdraw_reason" do
      expect(subject.withdraw_reason).to eq(trainee.withdraw_reason)
    end

    it "includes the additional_withdraw_reason" do
      expect(subject.additional_withdraw_reason).to eq(trainee.additional_withdraw_reason)
    end
  end

  describe "#academic_years" do
    before do
      allow(Trainees::SetAcademicCycles).to receive(:call) # deactivate so it doesn't override factories
    end

    context "with no end_academic_cycle set" do
      let!(:trainee) { create(:trainee, start_academic_cycle: current_cycle, end_academic_cycle: nil) }

      it "returns nil for academic_years" do
        expect(subject.academic_years).to be_nil
      end
    end

    context "when the trainee's course is one year" do
      let!(:trainee) { create(:trainee, start_academic_cycle: current_cycle, end_academic_cycle: current_cycle) }

      it "returns one academic year" do
        expect(subject.academic_years).to eq("#{current_cycle.start_year} to #{current_cycle.start_year + 1}")
      end
    end

    context "when the trainee spans multiple years" do
      let!(:trainee) { create(:trainee, start_academic_cycle: current_cycle, end_academic_cycle: next_cycle) }

      it "returns multiple academic years" do
        expect(subject.academic_years).to eq(
          "#{current_cycle.start_year} to #{current_cycle.start_year + 1}, #{next_cycle.start_year} to #{next_cycle.start_year + 1}",
        )
      end
    end
  end
end
