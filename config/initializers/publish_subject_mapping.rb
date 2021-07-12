# frozen_string_literal: true

PUBLISH_SUBJECT_SPECIALISM_MAPPING = Dttp::CodeSets::AllocationSubjects::MAPPING.values.each_with_object({}) do |metadata, hash|
  metadata[:subject_specialisms].each do |subject_specialism|
    if (publish_subject = subject_specialism[:publish_equivalent])
      hash[publish_subject] ||= []
      hash[publish_subject] << subject_specialism[:name]
    end
  end
end

PUBLISH_LANGUAGE_SUBJECTS = Dttp::CodeSets::AllocationSubjects::MAPPING[
  Dttp::CodeSets::AllocationSubjects::MODERN_LANGUAGES
][:subject_specialisms].map { |subject_specialism|
  subject_specialism[:publish_equivalent]
}.uniq
