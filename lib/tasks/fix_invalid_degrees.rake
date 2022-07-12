# frozen_string_literal: true

namespace :invalid_degrees do
  desc "imports a csv of trainees from a provided csv"
  task fix: :environment do
    Degree.uk.find_each do |degree|
      Degrees::FixToMatchReferenceData.call(degree: degree)
    end
  end
end
