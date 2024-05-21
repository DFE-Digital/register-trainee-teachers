# frozen_string_literal: true

namespace :cleanup do
  desc "Destroy trainees based on email list"
  task :discard_trainees, [:file_path] => :environment do |_t, args|
    raise "You must provide a file path" unless args[:file_path]

    emails = File.readlines(args[:file_path]).map(&:chomp)
    trainees = Trainee.where(email: emails)
    trainees.discard_all
    puts "Discarded #{trainees.count} trainee(s)"
  end
end
