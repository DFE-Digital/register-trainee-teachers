# frozen_string_literal: true

namespace :cleanup do
  desc "Discard users based on email list"
  task :discard_users, [:file_path] => :environment do |_t, args|
    raise "You must provide a file path" unless args[:file_path]

    emails = File.readlines(args[:file_path]).map(&:chomp).reject(&:empty?)
    users = User.where(email: emails)
    users.discard_all!
    puts "Discarded #{users.count} user(s)"
  end

end
