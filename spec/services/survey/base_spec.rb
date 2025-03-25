# frozen_string_literal: true

require "rails_helper"

module Survey
  describe Base do
    let(:trainee) { create(:trainee) }

    describe "abstract methods" do
      # Use allocate to create an instance without calling initialize
      let(:base_instance) do
        instance = described_class.allocate
        instance.instance_variable_set(:@trainee, trainee)
        instance
      end

      %i[
        survey_id
        mailing_list_id
        message_id
        subject
        embedded_data_for_contact
        embedded_data_for_distribution
        should_send_survey?
      ].each do |method_name|
        it "raises NotImplementedError for #{method_name}" do
          expect { base_instance.send(method_name) }.to raise_error(
            NotImplementedError, "Subclasses must implement #{method_name}"
          )
        end
      end
    end
  end
end
