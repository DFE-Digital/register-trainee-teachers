# frozen_string_literal: true

require "rails_helper"

describe TraineesController do
  let(:user) { build_current_user }

  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "#index" do
    context "no filters" do
      before do
        get(:index)
      end

      it "saves path to tracker" do
        tracker = FilteredBackLink::Tracker.new(session: session, href: trainees_path)
        expect(session[tracker.scope]).to eq("/trainees")
      end

      it "overrides saved path with new path" do
        tracker = FilteredBackLink::Tracker.new(session: session, href: trainees_path)
        expect(session[tracker.scope]).to eq("/trainees")

        get(:index, params: { "commit" => "Apply filters", "sort_by" => "", "text_search" => "", "state" => %w[draft], "subject" => "All subjects" })
        expect(session[tracker.scope]).to eq("/trainees?commit=Apply+filters&sort_by=&state%5B%5D=draft&subject=All+subjects&text_search=")
      end
    end

    context "with draft filter" do
      before do
        get(:index, params: { "commit" => "Apply filters", "sort_by" => "", "text_search" => "", "state" => %w[draft], "subject" => "All subjects" })
      end

      it "saves path to tracker" do
        tracker = FilteredBackLink::Tracker.new(session: session, href: trainees_path)
        expect(session[tracker.scope]).to eq("/trainees?commit=Apply+filters&sort_by=&state%5B%5D=draft&subject=All+subjects&text_search=")
      end
    end

    describe "error is not raised" do
      let(:trigger) do
        get(:index, params: { "commit" => "Apply filters", "sort_by" => "", "text_search" => "bug", "subject" => "chemistry" })
      end

      it { expect { trigger } .not_to raise_error }
    end

    describe "csv export" do
      context "with a provider user" do
        before do
          create(:trainee, :submitted_for_trn, provider: user.organisation)
          get(:index, format: "csv")
        end

        it "tracks activity" do
          activity = Activity.last
          expect(activity.controller_name).to eql("trainees")
          expect(activity.action_name).to eql("index")
          expect(activity.metadata).to eql({ "action" => "index", "controller" => "trainees", "format" => "csv" })
        end
      end

      context "with a lead partner user" do
        let(:user) { build_current_user(user: create(:user, :with_training_partner_organisation)) }

        it "returns a forbidden response" do
          enable_features(:user_can_have_multiple_organisations)
          get(:index, format: "csv")
          expect(response).to have_http_status(:forbidden)
        end
      end

      context "with an export request of over the system admin limit" do
        context "by a system admin" do
          let(:user) { build_current_user(user: create(:user, :system_admin)) }

          before do
            allow(Settings.trainee_export).to receive(:record_limit).and_return(0)
            create(:trainee, :submitted_for_trn)
            get(:index, format: "csv")
          end

          it "redirects" do
            enable_features(:user_can_have_multiple_organisations)
            get(:index, format: "csv")
            expect(response).to have_http_status(:found) # 302 redirect
          end
        end

        context "by a user" do
          before do
            allow(Settings.trainee_export).to receive(:record_limit).and_return(0)
            create(:trainee, :submitted_for_trn, provider: user.organisation)
            get(:index, format: "csv")
          end

          it "does not redirect" do
            enable_features(:user_can_have_multiple_organisations)
            get(:index, format: "csv")
            expect(response).to have_http_status(:ok)
          end
        end
      end
    end
  end

  describe "#show" do
    context "with a non-draft trainee" do
      let(:trainee) { create(:trainee, :submitted_for_trn, provider: user.organisation) }

      before do
        get(:show, params: { id: trainee })
      end

      it "saves the origin page" do
        expect(session["origin_pages_for_#{trainee.slug}"]).to eq(["/trainees/#{trainee.slug}"])
      end
    end

    context "with a draft trainee" do
      let(:trainee) { create(:trainee, :draft) }

      it "redirects to /review-draft" do
        expect(get(:show, params: { id: trainee })).to redirect_to(trainee_review_drafts_path(trainee))
      end
    end
  end
end
