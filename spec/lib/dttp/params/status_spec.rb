# frozen_string_literal: true

require "rails_helper"

module Dttp
  module Params
    describe Status do
      subject { described_class.new(status: status).params }

      describe "#params" do
        let(:status) { DttpStatuses::PROSPECTIVE_TRAINEE_TRN_REQUESTED }

        let(:expected_hash) do
          { "dfe_TraineeStatusId@odata.bind" => "/dfe_traineestatuses(#{Dttp::CodeSets::Statuses::MAPPING[status][:entity_id]})" }
        end

        it { is_expected.to eq(expected_hash) }
      end
    end
  end
end
