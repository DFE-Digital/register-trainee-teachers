# frozen_string_literal: true

namespace :audit do
  desc "Report trainees whose hesa_trainee_detail.funding_method is out of sync with Register state"
  task hesa_funding_method: :environment do
    total = 0
    mismatched = []

    Trainee.joins(:hesa_trainee_detail).find_each do |trainee|
      total += 1
      expected = Trainees::MapFundingToHesa.call(trainee:)
      actual = trainee.hesa_trainee_detail.funding_method
      next if expected == actual

      mismatched << { slug: trainee.slug, expected: expected, actual: actual }
    end

    puts "Checked #{total} trainees with hesa_trainee_detail"
    puts "Mismatched: #{mismatched.size}"

    mismatched.each do |row|
      puts "#{row[:slug]},#{row[:expected].inspect},#{row[:actual].inspect}"
    end
  end
end
