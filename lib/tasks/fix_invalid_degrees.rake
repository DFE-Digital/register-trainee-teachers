# frozen_string_literal: true

namespace :invalid_degrees do
  task fix_uk: :environment do
    Degree.uk.find_each do |degree|
      Degrees::FixToMatchReferenceData.call(degree:)
    end
  end

  task fix_non_uk: :environment do
    Degree.non_uk.find_each do |degree|
      Degrees::FixToMatchReferenceData.call(degree:)
    end
  end
end
