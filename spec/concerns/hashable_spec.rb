# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hashable do
  let(:klass) do
    Class.new do
      include Hashable
    end
  end

  let(:first_name) { Faker::Name.first_name }
  let(:last_name) { Faker::Name.last_name }
  let(:school_name) { Faker::Educator.primary_school }
  let(:city) { Faker::Address.city }
  let(:languages) { [Faker::Nation.language] }

  let(:hash) do
    {
      first_name: first_name,
      last_name: last_name,
      attributes: { school: { name: school_name } },
      metadata: { location: { city: } },
      interests: [{ id: 1 }, { basket: true }],
      languages: languages,
    }
  end

  describe "#deep_dig" do
    context "when the key value is a not a Hash or an Array" do
      it "returns the value of the key" do
        expect(klass.new.deep_dig(hash, :last_name)).to eq(last_name)
      end
    end

    context "when the key value is a Hash" do
      it "returns the value of the key" do
        expect(klass.new.deep_dig(hash, :name)).to eq(school_name)
        expect(klass.new.deep_dig(hash, :city)).to eq(city)
      end
    end

    context "when the key value is an Array" do
      it "returns the value of the key" do
        expect(klass.new.deep_dig(hash, :languages)).to eq(languages)
        expect(klass.new.deep_dig(hash, :basket)).to be(true)
      end
    end

    context "when the key does not exists" do
      it "returns nil" do
        expect(klass.new.deep_dig(hash, :age)).to be_nil
      end
    end
  end
end
