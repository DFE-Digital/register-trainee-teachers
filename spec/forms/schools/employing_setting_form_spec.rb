# frozen_string_literal: true

require "rails_helper"

module Schools
  describe EmployingSettingForm, type: :model do
    let(:trainee) { create(:trainee, :early_years_teacher_degree_apprenticeship) }
    let(:params) do
      {
        employing_school_name: "Sunshine Day Nursery",
        employing_school_address_line_one: "12 Mill Lane",
        employing_school_town: "Harrogate",
        employing_school_postcode: "HG1 4QT",
      }
    end

    subject(:form) { described_class.new(trainee, params:) }

    it { is_expected.to be_valid }

    it "needs a real postcode" do
      form = described_class.new(trainee, params: params.merge(employing_school_postcode: "not a postcode"))
      expect(form).not_to be_valid
      expect(form.errors[:employing_school_postcode]).to include("Enter a real postcode")
    end

    it "doesn't need address line 2" do
      expect(form.errors[:employing_school_address_line_two]).to be_empty
    end

    context "with a setting found in the search" do
      let(:school) { create(:school, urn: "107823") }

      it "takes the URN from the setting, not from what's sent" do
        form = described_class.new(trainee, params: params.merge(employing_school_id: school.id, employing_school_urn: "999999"))
        expect(form.employing_school_urn).to eq("107823")
      end
    end

    it "saves the setting as applicable" do
      trainee.update!(employing_school_not_applicable: true)
      form.save!
      expect(trainee.reload).to have_attributes(employing_school_not_applicable: false, employing_school_town: "Harrogate", employing_school_urn: nil)
    end
  end
end
