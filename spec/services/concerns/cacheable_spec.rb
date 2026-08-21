# frozen_string_literal: true

require "rails_helper"

describe Cacheable do
  let(:dummy_class) do
    Class.new { include Cacheable }.tap do |klass|
      klass.const_set(:FORM_SECTION_KEYS, %i[contact_details])
    end
  end

  let(:id) { 1 }
  let(:key) { :contact_details }
  let(:values) { { "email" => "trainee@example.com" } }
  let(:solid_cache) { ActiveSupport::Cache::MemoryStore.new }

  before do
    allow(Rails).to receive(:cache).and_return(solid_cache)
  end

  describe "#get" do
    context "when the entry exists" do
      before do
        dummy_class.set(id, key, values)
      end

      it "returns the stored value" do
        expect(dummy_class.get(id, key)).to eq(values)
      end

      it "counts a solid cache hit" do
        expect(Yabeda.form_store.reads_total).to receive(:increment).with({ key: key, outcome: :solid_cache_hit })

        dummy_class.get(id, key)
      end
    end

    context "when the entry does not exist" do
      it "returns nil" do
        expect(dummy_class.get(id, key)).to be_nil
      end

      it "counts a miss" do
        expect(Yabeda.form_store.reads_total).to receive(:increment).with({ key: key, outcome: :miss })

        dummy_class.get(id, key)
      end
    end
  end

  describe "#set" do
    it "writes to Solid Cache" do
      dummy_class.set(id, key, values)

      expect(JSON.parse(solid_cache.read(dummy_class.cache_key_for(id, key)))).to eq(values)
    end

    it "counts a write" do
      expect(Yabeda.form_store.writes_total).to receive(:increment).with({ key: key, backend: :solid_cache })

      dummy_class.set(id, key, values)
    end

    context "without a valid form section key" do
      it "raises an error and counts nothing" do
        expect(Yabeda.form_store.writes_total).not_to receive(:increment)

        expect { dummy_class.set(id, :not_a_form_section, values) }.to raise_error(described_class::InvalidKeyError)
      end
    end
  end

  describe "#clear_all" do
    before do
      dummy_class.set(id, key, values)
    end

    it "clears the entry" do
      dummy_class.clear_all(id)

      expect(dummy_class.get(id, key)).to be_nil
    end
  end
end
