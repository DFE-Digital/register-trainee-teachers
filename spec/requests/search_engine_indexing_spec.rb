require "rails_helper"

RSpec.describe "Search engine indexing", type: :request do
  %w[production].each do |env|
    context "when the ENV is #{env}" do
      before do
        allow(Rails).to receive(:env).and_return(
          ActiveSupport::StringInquirer.new(env)
        )

        get root_path
      end

      it "does not render the no index, nofollow meta tag" do
        expect(response.body).not_to include(
          '<meta name="robots" content="noindex, nofollow">'
        )
      end
    end
  end

  %w[staging productiondata sandbox qa pen review].each do |env|
    context "when the ENV is #{env}" do
      before do
        allow(Rails).to receive(:env).and_return(
          ActiveSupport::StringInquirer.new(env)
        )

        get root_path
      end

      it "renders the no index, nofollow meta tag" do
        expect(response.body).to include(
          '<meta name="robots" content="noindex, nofollow">'
        )
      end
    end
  end
end
