# frozen_string_literal: true

require "rails_helper"

describe PageTracker do
  let(:session) { {} }
  let(:trainee) { build(:trainee) }
  let(:path_a) { "/trainees/#{trainee.slug}/review-draft" }
  let(:path_b) { "/trainees/#{trainee.slug}/personal-details/confirm" }
  let(:path_c) { "/trainees/#{trainee.slug}/personal-details/edit" }
  let(:history_session_key) { "history_for_#{trainee.slug}" }
  let(:origin_pages_session_key) { "origin_pages_for_#{trainee.slug}" }

  describe "#save!" do
    context "within trainee specific pages" do
      context "Non-GET Request" do
        let(:request) { double(fullpath: path_a, head?: false, get?: false, patch?: true, put?: false) }

        before do
          PageTracker.new(trainee_slug: trainee.slug, session: session, request: request).save!
        end

        it "doesn't record the URL to history" do
          expect(session[history_session_key]).to be_empty
        end
      end

      context "2 requests are tracked" do
        let(:request_a) { double(fullpath: path_a, head?: false, get?: true, patch?: false, put?: false) }
        let(:request_b) { double(fullpath: path_b, head?: false, get?: true, patch?: false, put?: false) }

        before do
          PageTracker.new(trainee_slug: trainee.slug, session: session, request: request_a).save!
          PageTracker.new(trainee_slug: trainee.slug, session: session, request: request_b).save!
        end

        it "stores the pages in the order they were requested" do
          expect(session[history_session_key]).to eq([path_a, path_b])
        end
      end
    end

    context "outside a trainee page" do
      let(:session) { { history_session_key => [path_a, path_b] } }
      let(:request) { double(fullpath: "/", referer: path_a, head?: false, get?: true, patch?: false, put?: false) }

      before do
        PageTracker.new(trainee_slug: trainee.slug, session: session, request: request).save!
      end

      it "ignores the request and removes all session history for that trainee" do
        expect(session[history_session_key]).to be_nil
      end
    end

    context "exiting a page currently stored in history" do
      let(:session) { { history_session_key => [path_a, path_b] } }
      let(:request) { double(fullpath: path_a, head?: false, get?: true, patch?: false, put?: false) }

      before do
        PageTracker.new(trainee_slug: trainee.slug, session: session, request: request).save!
      end

      it "it removes that page from history" do
        expect(session[history_session_key]).to eq([path_a])
      end
    end
  end

  describe "#save_as_origin!" do
    context "2 requests are tracked" do
      let(:request_a) { double(fullpath: path_a, head?: false, get?: true, patch?: false, put?: false) }
      let(:request_b) { double(fullpath: path_b, head?: false, get?: true, patch?: false, put?: false) }

      before do
        PageTracker.new(trainee_slug: trainee.slug, session: session, request: request_a).save_as_origin!
        PageTracker.new(trainee_slug: trainee.slug, session: session, request: request_b).save_as_origin!
      end

      it "stores the pages in the order they were requested" do
        expect(session[origin_pages_session_key]).to eq([path_a, path_b])
      end
    end

    context "exiting the last origin page currently stored in history" do
      let(:session) { { origin_pages_session_key => [path_a, path_b] } }
      let(:request) { double(fullpath: path_a, head?: false, get?: true, patch?: false, put?: false) }

      before do
        PageTracker.new(trainee_slug: trainee.slug, session: session, request: request).save_as_origin!
      end

      it "it removes that page from origin pages" do
        expect(session[origin_pages_session_key]).to eq([path_a])
      end
    end
  end

  describe "#previous_page_path" do
    context "entered an edit page (path_c) directly because it's a new trainee bypassing confirm page (path_b)" do
      let(:session) { { history_session_key => [path_a, path_c], origin_pages_session_key => [path_a, path_b] } }
      let(:request) { double(fullpath: path_c, head?: false, get?: true, patch?: false, put?: false) }

      it "returns the path to last origin page" do
        page_tracker = PageTracker.new(trainee_slug: trainee.slug, session: session, request: request)

        expect(page_tracker.previous_page_path).to eq(path_b)
      end
    end

    context "on a consecutive edit page" do
      let(:session) { { history_session_key => [path_a, path_c, path_d], origin_pages_session_key => [path_a, path_b] } }
      let(:request) { double(fullpath: path_c, head?: false, get?: true, patch?: false, put?: false) }
      let(:path_d) { "/trainees/#{trainee.slug}/lead-schools/edit" }

      it "returns the path to last history page" do
        page_tracker = PageTracker.new(trainee_slug: trainee.slug, session: session, request: request)

        expect(page_tracker.previous_page_path).to eq(path_c)
      end
    end

    context "on a confirm page" do
      let(:session) { { origin_pages_session_key => [path_a, path_b] } }
      let(:request) { double(fullpath: path_b, head?: false, get?: true, patch?: false, put?: false) }

      it "returns the path to the previous confirm page" do
        page_tracker = PageTracker.new(trainee_slug: trainee.slug, session: session, request: request)

        expect(page_tracker.previous_page_path).to eq(path_a)
      end
    end

    context "on a non-confirm page" do
      let(:session) { { history_session_key => [path_a, path_b, path_c] } }
      let(:request) { double(fullpath: path_c, head?: false, get?: true, patch?: false, put?: false) }

      it "returns the path to the previous confirm page" do
        page_tracker = PageTracker.new(trainee_slug: trainee.slug, session: session, request: request)

        expect(page_tracker.previous_page_path).to eq(path_b)
      end
    end
  end

  describe "#last_origin_page_path" do
    context "on a non-confirm page" do
      let(:session) { { origin_pages_session_key => [path_a, path_b] } }
      let(:request) { double(fullpath: path_b, head?: false, get?: true, patch?: false, put?: false) }

      it "returns the path to the previous confirm page" do
        page_tracker = PageTracker.new(trainee_slug: trainee.slug, session: session, request: request)

        expect(page_tracker.last_origin_page_path).to eq(path_a)
      end
    end

    context "on a non-confirm page" do
      let(:session) { { origin_pages_session_key => [path_a, path_b] } }
      let(:request) { double(fullpath: path_b, head?: false, get?: true, patch?: false, put?: false) }

      it "returns the path to the previous confirm page" do
        page_tracker = PageTracker.new(trainee_slug: trainee.slug, session: session, request: request)
        expect(page_tracker.previous_page_path).to eq(path_a)
      end
    end
  end

  describe "#last_non_confirm_origin_page_path" do
    context "when you've been to a confirm page" do
      let(:session) { { origin_pages_session_key => [path_a, path_b] } }
      let(:request) { double(fullpath: path_c, head?: false, get?: true, patch?: false, put?: false) }

      it "returns the path to the previous origin page" do
        page_tracker = PageTracker.new(trainee_slug: trainee.slug, session: session, request: request)
        expect(page_tracker.last_non_confirm_origin_page_path).to eq(path_a)
      end
    end
  end
end
