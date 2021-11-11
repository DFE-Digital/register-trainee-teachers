# frozen_string_literal: true

require "rails_helper"

describe TraineesController do
  let(:user) { create(:user) }

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

    context "csv export" do
      let(:trainee) { create(:trainee, :submitted_for_trn, provider: user.provider) }

      before do
        trainee
        get(:index, format: "csv")
      end

      it "tracks activity" do
        activity = Activity.last
        expect(activity.controller_name).to eql("trainees")
        expect(activity.action_name).to eql("index")
        expect(activity.metadata).to eql({ "action" => "index", "controller" => "trainees", "format" => "csv" })
      end
    end
  end

  describe "#show" do
    context "with a non-draft trainee" do
      let(:trainee) { create(:trainee, :submitted_for_trn, provider: user.provider) }

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

  describe "#destroy" do
    context "with a non-draft trainee" do
      let(:trainee) { create(:trainee, :submitted_for_trn, provider: user.provider) }

      it "redirects to the trainee index page" do
        expect(get(:destroy, params: { id: trainee })).to redirect_to(trainees_path)
      end
    end
  end
end
