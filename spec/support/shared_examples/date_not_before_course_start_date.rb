# frozen_string_literal: true

RSpec.shared_examples "date is not before itt start date" do |form|
  context "date is before the itt start date" do
    before do
      subject.year = trainee.itt_start_date.year - 1
      subject.validate
    end

    it "is invalid" do
      expect(subject.errors[:date]).to include(I18n.t("activemodel.errors.models.#{form}.attributes.date.not_before_itt_start_date"))
    end
  end
end
