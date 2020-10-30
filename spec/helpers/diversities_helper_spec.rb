require "rails_helper"

describe DiversitiesHelper do
  include DiversitiesHelper

  describe "#back_link" do
    context "trainee with ethic group" do
      subject do
        helper.back_link(trainee)
      end
      let(:trainee) do
        create(:trainee,
               ethnic_group: Diversities::ETHNIC_GROUP_ENUMS[:not_provided])
      end
      it "return correct path" do
        expect(subject).to eq edit_trainee_diversity_ethnic_group_path(trainee)
      end
      context "with ethic background" do
        let(:trainee) do
          asian = Diversities::ETHNIC_GROUP_ENUMS[:asian]

          create(:trainee,
                 ethnic_group: asian,
                 ethnic_background: Diversities::BACKGROUNDS[asian].sample)
        end
        it "return correct path" do
          expect(subject).to eq edit_trainee_diversity_ethnic_background_path(trainee)
        end
      end
    end
  end
end
