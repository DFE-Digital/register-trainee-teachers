# frozen_string_literal: true

require "rails_helper"

describe UserSearch do
  describe "#call" do
    let!(:user) { create(:user, first_name: "Jane", last_name: "Smith", email: "j.smith@mdx.ac.uk") }
    let!(:other_user) { create(:user, first_name: "Bob", last_name: "Jones", email: "bob.jones@example.com") }

    it "can search by dotted email address" do
      expect(described_class.call(query: "j.smith@mdx.ac.uk").users).to match([user])
    end

    it "can search by email address case-insensitively" do
      expect(described_class.call(query: "J.Smith@MDX.AC.UK").users).to match([user])
    end

    it "can search by last name" do
      expect(described_class.call(query: "Smith").users).to match([user])
    end

    it "can search by first name" do
      expect(described_class.call(query: "Jane").users).to match([user])
    end

    context "too many results" do
      before { create_list(:user, 2, last_name: user.last_name) }

      it "supports truncation" do
        expect(described_class.call(query: user.last_name, limit: 1).users.size).to eq(1)
      end
    end

    context "limit" do
      it "can set a limit for the returned results" do
        expect(described_class.call(query: user.email, limit: 10).limit).to eq(10)
      end
    end
  end
end
