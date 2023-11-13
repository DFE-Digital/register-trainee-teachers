# frozen_string_literal: true

namespace :lint do
  desc "Lint Ruby code"
  task ruby: :environment do
    puts "Linting ruby..."
    system("bundle exec rubocop app config db lib spec Gemfile --format clang -a") || exit($CHILD_STATUS.exitstatus)
  end

  desc "Lint erb files"
  task erb: :environment do
    puts "Linting erb files..."
    system("bundle exec erblint app") || exit($CHILD_STATUS.exitstatus)
  end

  desc "Lint JavaScript code"
  task javascript: :environment do
    puts "Linting javascript..."
    system("yarn run js:lint") || exit($CHILD_STATUS.exitstatus)
  end

  desc "Lint Scss"
  task scss: :environment do
    puts "Linting scss..."
    system("yarn run scss:lint") || exit($CHILD_STATUS.exitstatus)
  end
end
