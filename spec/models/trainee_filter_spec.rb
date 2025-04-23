# frozen_string_literal: true

require "rails_helper"

describe TraineeFilter do
  let(:permitted_params) do
    ActionController::Parameters.new(params)
      .permit(
        :provider,
        :start_year,
        :subject,
        :text_search,
        :has_trn,
        academic_year: [],
        training_route: [],
        state: [],
        record_source: [],
        study_mode: [],
      )
  end

  subject { TraineeFilter.new(params: permitted_params) }

  returns_nil = "returns nil"

  shared_examples returns_nil do
    it returns_nil do
      expect(subject.filters).to be_nil
    end
  end

  describe "#filters" do
    before do
      create(:academic_cycle, :current)
    end

    context "with fully valid parameters" do
      let(:params) do
        {
          subject: "Biology",
          text_search: "search terms",
          training_route: [TRAINING_ROUTE_ENUMS[:assessment_only]],
          status: %w[course_not_started],
        }
      end

      it "returns the correct filter hash" do
        expect(subject.filters).to eq(permitted_params.to_h)
      end
    end

    context "with provider" do
      let(:provider) { create(:provider) }
      let(:params) { { provider: provider.id } }

      it "returns the provider from the DB" do
        expect(subject.filters).to eq({ "provider" => provider })
      end
    end

    context "with previous academic years" do
      let(:academic_year_filter) do
        build(:academic_cycle, previous_cycle: true).start_year.to_s
      end
      let(:params) { { academic_year: [academic_year_filter] } }

      it "applies the academic year" do
        expect(subject.filters).to eq({ "academic_year" => [academic_year_filter] })
      end
    end

    context "with current academic years" do
      let(:academic_year_filter) do
        build(:academic_cycle, :current).start_year.to_s
      end
      let(:params) { { academic_year: [academic_year_filter] } }

      it "applies the academic year" do
        expect(subject.filters).to eq({ "academic_year" => [academic_year_filter] })
      end
    end

    context "with lowercase subject" do
      let(:subject_filter) { "japanese" }
      let(:params) { { subject: subject_filter } }

      it "returns the subject as stored correctly cased in the DB" do
        expect(subject.filters).to eq({ "subject" => subject_filter })
      end
    end

    context "with start year" do
      let(:start_year_filter) { "2022" }
      let(:params) { { start_year: start_year_filter } }

      before do
        create(:academic_cycle, cycle_year: 2022)
      end

      it "applies the start year as stored in the DB" do
        expect(subject.filters).to eq({ "start_year" => start_year_filter })
      end
    end

    context "with 'All subjects'" do
      let(:params) { { subject: "All subjects" } }

      it_behaves_like returns_nil
    end

    context "with invalid record_source" do
      let(:params) { { record_source: %w[hackerman] } }

      it_behaves_like returns_nil
    end

    context "with invalid training route" do
      let(:params) { { training_route: %w[not_a_training_route] } }

      it_behaves_like returns_nil
    end

    context "with invalid status" do
      let(:params) { { status: %w[not_a_status] } }

      it_behaves_like returns_nil
    end

    context "with invalid provider id" do
      let(:params) { { provider: "not an id" } }

      it_behaves_like returns_nil
    end

    context "with empty params" do
      let(:params) { {} }

      it_behaves_like returns_nil
    end

    context "with trainee start year" do
      let(:params) { { trainee_start_year: ["2020"] } }

      subject { TraineeFilter.new(params:) }

      it "returns trainee_start_year in hash" do
        expect(subject.filters).to eq({ "trainee_start_year" => ["2020"] })
      end
    end

    context "with trainee status" do
      let(:params) { { status: ["in_training"] } }

      subject { TraineeFilter.new(params:) }

      it "returns trainee_start_year in hash" do
        expect(subject.filters).to eq({ "status" => ["in_training"] })
      end
    end

    context "with has_trn" do
      let(:params) { { has_trn: } }

      subject { TraineeFilter.new(params:) }

      context "when has_trn is true" do
        let(:has_trn) { "true" }

        it "returns has_trn in hash" do
          expect(subject.filters).to eq({ "has_trn" => true })
        end
      end

      context "when has_trn is false" do
        let(:has_trn) { "false" }

        it "returns has_trn in hash" do
          expect(subject.filters).to eq({ "has_trn" => false })
        end
      end

      context "when has_trn is nil" do
        let(:has_trn) { nil }

        it "returns has_trn in hash" do
          expect(subject.filters).to be_nil
        end
      end

      context "when has_trn is empty" do
        let(:has_trn) { "" }

        it "returns has_trn in hash" do
          expect(subject.filters).to be_nil
        end
      end
    end
  end
end
