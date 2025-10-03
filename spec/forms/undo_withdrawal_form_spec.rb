# frozen_string_literal: true

require "rails_helper"

describe UndoWithdrawalForm, type: :model do
  let(:trainee) { create(:trainee, :withdrawn) }
  let(:session) { {} }
  let(:comment) { "This trainee should not have been withdrawn" }
  let(:ticket) { "TICKET-123" }
  let(:params) { { comment:, ticket: } }

  subject { described_class.new(trainee:, session:, comment:, ticket:) }

  describe "validations" do
    context "when comment is present" do
      it "is valid" do
        expect(subject).to be_valid
      end
    end

    context "when comment is blank" do
      let(:comment) { "" }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:comment]).to include("Enter a comment")
      end
    end

    context "when comment is nil" do
      let(:comment) { nil }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:comment]).to include("Enter a comment")
      end
    end
  end

  describe "#initialize" do
    context "when comment and ticket are provided" do
      it "sets the attributes correctly" do
        expect(subject.comment).to eq(comment)
        expect(subject.ticket).to eq(ticket)
        expect(subject.trainee).to eq(trainee)
        expect(subject.session).to eq(session)
      end
    end

    context "when comment and ticket are in session" do
      let(:session) { { undo_withdrawal_comment: "Session comment", undo_withdrawal_ticket: "SESSION-456" } }
      let(:form) { described_class.new(trainee:, session:) }

      it "uses values from session" do
        expect(form.comment).to eq("Session comment")
        expect(form.ticket).to eq("SESSION-456")
      end
    end

    context "when params override session values" do
      let(:session) { { undo_withdrawal_comment: "Old comment", undo_withdrawal_ticket: "OLD-456" } }

      it "uses provided params and updates session" do
        expect(subject.comment).to eq(comment)
        expect(subject.ticket).to eq(ticket)
        expect(session[:undo_withdrawal_comment]).to eq(comment)
        expect(session[:undo_withdrawal_ticket]).to eq(ticket)
      end
    end
  end

  describe "#save" do
    context "when form is valid" do
      it "returns true" do
        expect(subject.save).to be_truthy
      end

      it "discards the current withdrawal" do
        Timecop.freeze do
          subject.save
          expect(trainee.trainee_withdrawals.last.discarded_at.iso8601).to eq(Time.zone.now.iso8601)
        end
      end

      it "updates trainee to previous state" do
        subject.save
        expect(trainee.reload.state).to eq("trn_received")
      end

      it "sets an audit comment with the comment and ticket" do
        subject.save
        expect(trainee.reload.audits.last.comment).to eq("#{comment}\n#{ticket}")
      end

      it "clears session data" do
        subject.save
        expect(session[:undo_withdrawal_comment]).to be_nil
        expect(session[:undo_withdrawal_ticket]).to be_nil
      end

      context "when ticket is nil" do
        let(:ticket) { nil }

        it "sets an audit comment with just the comment" do
          subject.save

          expect(trainee.reload.audits.last.comment).to eq(comment)
        end
      end
    end

    context "when form is invalid" do
      let(:comment) { "" }

      it "returns false" do
        expect(subject.save).to be false
      end

      it "does not update the trainee" do
        expect { subject.save }.not_to change { trainee.reload.state }
      end

      it "does not discard the withdrawal" do
        expect { subject.save }.not_to change { trainee.trainee_withdrawals.last.reload.discarded_at }
      end
    end
  end

  describe "#previous_state" do
    it "returns the state before withdrawal" do
      expect(subject.previous_state).to eq("trn_received")
    end

    context "when no previous state is found in audits" do
      before do
        trainee.audits.destroy_all
      end

      it "defaults to trn_received" do
        expect(subject.previous_state).to eq("trn_received")
      end
    end
  end

  describe "#delete!" do
    before do
      session[:undo_withdrawal_comment] = "test comment"
      session[:undo_withdrawal_ticket] = "test ticket"
    end

    it "removes the comment and ticket from the session" do
      subject.delete!
      expect(session[:undo_withdrawal_comment]).to be_nil
      expect(session[:undo_withdrawal_ticket]).to be_nil
    end
  end

  describe "#audit_comment" do
    context "when both the comment and ticket are present" do
      it "joins them with newline" do
        expect(subject.send(:audit_comment)).to eq("#{comment}\n#{ticket}")
      end
    end

    context "when only the comment is present" do
      let(:ticket) { nil }

      it "returns only the comment" do
        expect(subject.send(:audit_comment)).to eq(comment)
      end
    end

    context "when only the ticket is present" do
      let(:comment) { nil }

      subject { described_class.new(trainee:, session:, ticket:) }

      it "returns only the ticket" do
        expect(subject.send(:audit_comment)).to eq(ticket)
      end
    end
  end
end
