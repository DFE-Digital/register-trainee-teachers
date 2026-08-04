# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V20261::HesaMapper::DegreeAttributes do
  def normalise(attributes)
    attributes.transform_values do |value|
      if value.class.name.to_s.include?("InvalidValue")
        [:invalid, value.instance_variables.index_with { |ivar| value.instance_variable_get(ivar) }]
      else
        value
      end
    end
  end

  def divergences_for(params_list)
    params_list.each_with_object([]) do |params, out|
      gem_output = normalise(GemDegreeAttributesMapper.call(params))
      yaml_output = normalise(described_class.call(params))
      out << "#{params.inspect}\n  gem:  #{gem_output}\n  yaml: #{yaml_output}" if gem_output != yaml_output
    end
  end

  def codes_for(collection, field)
    collection.all.map { |record| record.public_send(field) }.compact.map(&:to_s).reject(&:empty?).uniq
  end

  it "maps every subject code the same as the gem" do
    params = codes_for(DfEReference::DegreesQuery::SUBJECTS, :hecos_code).map { |code| { subject: code, institution: "0001", uk_degree: "002", grade: "01" } }
    expect(divergences_for(params)).to be_empty
  end

  it "maps every institution code the same as the gem" do
    params = codes_for(DfEReference::DegreesQuery::INSTITUTIONS, :hesa_itt_code).map { |code| { subject: "100104", institution: code, uk_degree: "002", grade: "01" } }
    expect(divergences_for(params)).to be_empty
  end

  it "maps every degree type code the same as the gem" do
    params = codes_for(DfEReference::DegreesQuery::TYPES, :hesa_itt_code).map { |code| { subject: "100104", institution: "0001", uk_degree: code, grade: "01" } }
    expect(divergences_for(params)).to be_empty
  end

  it "maps every grade code the same as the gem" do
    params = codes_for(DfEReference::DegreesQuery::GRADES, :hesa_code).map { |code| { subject: "100104", institution: "0001", uk_degree: "002", grade: code } }
    expect(divergences_for(params)).to be_empty
  end

  def country_stored_for(code)
    described_class.call({ country: code, subject: "100104", non_uk_degree: "051", grade: "01" })[:country]
  end

  def country_codes_stored_on_degrees
    Hesa::CodeSets::Countries::MAPPING.reject { |_, name| Hesa::CodeSets::Countries::UK_COUNTRIES.include?(name) }.keys
  end

  it "does not store a country for UK degrees, which carry locale_code instead" do
    uk_codes = Hesa::CodeSets::Countries::MAPPING.keys - country_codes_stored_on_degrees

    expect(uk_codes.map { |code| country_stored_for(code) }).to all(be_nil)
  end

  it "maps country to the label the UI writes" do
    ui_labels = DfE::ReferenceData::CountriesAndTerritories::COUNTRIES_AND_TERRITORIES.all.map(&:name).compact.uniq
    codes = country_codes_stored_on_degrees

    divergences = ui_labels.each_with_object([]) do |ui_label, out|
      code = ReferenceData::COUNTRIES.hesa_code_for(ui_label)
      next unless codes.include?(code)

      actual = country_stored_for(code)
      out << "#{code}: #{actual.inspect} != #{ui_label.inspect}" if actual != ui_label
    end
    expect(divergences).to be_empty, divergences.join("\n")
  end

  it "maps every country code to a label that serializes back to the same code" do
    divergences = country_codes_stored_on_degrees.each_with_object([]) do |code, out|
      stored = country_stored_for(code)
      resolved = ReferenceData::COUNTRIES.hesa_code_for(stored)
      out << "#{code}: stored #{stored.inspect}, which serializes back as #{resolved.inspect}" if resolved != code
    end
    expect(divergences).to be_empty, divergences.join("\n")
  end

  it "remaps Institute of Education to UCL the same as the gem" do
    expect(divergences_for([{ subject: "100104", institution: "0133", uk_degree: "002", grade: "01" }])).to be_empty
  end

  it "remaps pass-without-honours to the nearest equivalent grade the same as the gem" do
    expect(divergences_for([{ subject: "100104", institution: "0001", uk_degree: "002", grade: "09" }])).to be_empty
  end

  it "falls back to Other UK institution the same as the gem" do
    expect(divergences_for([{ subject: "100104", uk_degree: "002", grade: "01" }])).to be_empty
  end
end
