# frozen_string_literal: true

require "rails_helper"

describe Persona do
  describe ".notable_user_ids" do
    let(:persona_user) { create(:user) }
    let(:not_notable_user) { create(:user) }
    let(:notable_users) { create_list(:user, 10) }

    let(:notable_user_ids) { notable_users.pluck(:id) }
    let(:popular_providers) { notable_users.flat_map(&:providers) }

    before do
      persona_user
      popular_providers.each do |provider|
        create_list(:trainee, 5, provider:)
      end
      create_list(:trainee, 4, provider: not_notable_user.providers.first)
    end

    subject { described_class.notable_user_ids }

    it "returns notable user ids" do
      expect(subject).to match_array(notable_user_ids)
    end

    context "with PERSONA_IDS" do
      it "returns the persona user ids & notable user ids" do
        stub_const("PERSONA_IDS", [persona_user.id])
        expect(subject).to match_array([persona_user.id] + notable_user_ids)
      end
    end
  end

  describe ".default_scope" do
    let(:persona_user) { create(:user) }
    let(:notable_users) { create_list(:user, 10) }

    let(:notable_user_ids) { notable_users.pluck(:id) }
    let(:popular_providers) { notable_users.flat_map(&:providers) }

    before do
      persona_user
      popular_providers.each do |provider|
        create_list(:trainee, 5, provider:)
      end
    end

    subject { described_class.pluck(:id) }

    it "returns notable user ids" do
      expect(subject).to match_array(notable_user_ids)
    end

    context "with PERSONA_EMAILS" do
      it "returns persona user ids & notable user ids" do
        stub_const("PERSONA_EMAILS", [persona_user.email])
        expect(subject).to match_array([persona_user.id] + notable_user_ids)
      end
    end

    context "with PERSONA_IDS" do
      it "returns the persona user ids & notable user ids" do
        stub_const("PERSONA_IDS", [persona_user.id])
        expect(subject).to match_array([persona_user.id] + notable_user_ids)
      end
    end
  end
end
