# frozen_string_literal: true

require "rails_helper"

module SystemAdmin
  describe FundingUploadForm, type: :model do
    subject { described_class.new }

    it { is_expected.to validate_presence_of(:funding_type) }
    it { is_expected.to validate_presence_of(:month) }
    it { is_expected.to validate_presence_of(:file) }
  end
end
