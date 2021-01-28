# frozen_string_literal: true

require "rails_helper"

describe OriginPage do
  let(:trainee_path) { "/trainees/#{trainee.slug}" }
  let(:review_draft_trainee_path) { "/trainees/#{trainee.slug}/review-draft" }
  let(:trainee_personal_details_confirm_path) { "/trainees/#{trainee.slug}/personal-details/confirm" }
  let(:session) { { "origin_pages_for_#{trainee.id}" => origin_pages } }

  subject { described_class.new(trainee, session, request) }

  describe "#path" do
    context "trainee not in draft" do
      let(:trainee) { create(:trainee, :submitted_for_trn) }

      context "GET request" do
        let(:request) { double(path_info: request_path, head?: false, get?: true, patch?: false, put?: false) }

        context "no origin pages saved" do
          let(:request_path) { review_draft_trainee_path }
          let(:origin_pages) { [] }

          it "returns the path to trainee review draft page" do
            expect(subject.path).to eq(trainee_path)
          end
        end
      end
    end

    context "trainee is in draft state" do
      let(:trainee) { create(:trainee, :draft) }

      context "GET request" do
        let(:request) { double(path_info: request_path, head?: false, get?: true, patch?: false, put?: false) }

        context "no origin pages saved" do
          let(:request_path) { review_draft_trainee_path }
          let(:origin_pages) { [] }

          it "returns the path to trainee review draft page" do
            expect(subject.path).to eq(review_draft_trainee_path)
          end
        end

        context "1 origin page saved" do
          let(:request_path) { review_draft_trainee_path }
          let(:origin_pages) { %w[review_draft_trainee] }

          it "returns the path to the last origin page" do
            expect(subject.path).to eq(review_draft_trainee_path)
          end
        end

        context "2 origin pages saved" do
          let(:request_path) { trainee_personal_details_confirm_path }
          let(:origin_pages) { %w[review_draft_trainee trainee_personal_details_confirm] }

          it "returns the path to the first origin page" do
            expect(subject.path).to eq(review_draft_trainee_path)
          end
        end
      end

      context "PUT request" do
        let(:request_path) { trainee_personal_details_confirm_path }
        let(:request) { double(path_info: request_path, head?: false, get?: false, patch?: false, put?: true) }

        context "2 origin pages saved" do
          let(:origin_pages) { %w[review_draft_trainee trainee_personal_details_confirm] }

          context "last page visited was a confirmation page" do
            it "returns the path to the page before the confirmation page" do
              expect(subject.path).to eq(review_draft_trainee_path)
            end
          end
        end
      end
    end
  end

  describe "#save" do
    let(:trainee) { create(:trainee) }
    let(:request_path) { review_draft_trainee_path }
    let(:request) { double(path_info: request_path, head?: false, get?: true, patch?: false, put?: false) }

    before do
      subject.save
    end

    context "origin pages is empty" do
      let(:origin_pages) { [] }

      it "stores the request path" do
        expect(session["origin_pages_for_#{trainee.id}"]).to eq(%w[review_draft_trainee])
      end
    end

    context "origin pages contains only the request path" do
      let(:origin_pages) { %w[review_draft_trainee] }

      it "is a noop" do
        expect(session["origin_pages_for_#{trainee.id}"]).to eq(origin_pages)
      end
    end

    context "origin pages contains one different path" do
      let(:request_path) { trainee_personal_details_confirm_path }
      let(:origin_pages) { %w[review_draft_trainee] }

      it "appends the request path" do
        expect(session["origin_pages_for_#{trainee.id}"]).to eq(%w[review_draft_trainee trainee_personal_details_confirm])
      end
    end

    context "origin pages includes the request path last" do
      let(:request_path) { review_draft_trainee_path }
      let(:origin_pages) { %w[trainee_personal_details_confirm review_draft_trainee] }

      it "is a noop" do
        expect(session["origin_pages_for_#{trainee.id}"]).to eq(origin_pages)
      end
    end

    # i.e. you're returning to an origin page, after having been on another - we
    # still need to save it!
    context "origin pages includes the request path, but not last" do
      let(:request_path) { review_draft_trainee_path }
      let(:origin_pages) { %w[review_draft_trainee trainee_personal_details_confirm] }

      it "appends the request path" do
        expect(session["origin_pages_for_#{trainee.id}"]).to eq(%w[trainee_personal_details_confirm review_draft_trainee])
      end
    end
  end
end
