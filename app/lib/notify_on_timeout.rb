# frozen_string_literal: true

module NotifyOnTimeout
  def send_message_to_slack(trainee, class_name)
    SlackNotifierService.call(
      message: "#{class_name} for Trainee with slug: #{trainee.slug} has timed out after #{Settings.jobs.max_poll_duration_days} days.\n#{Settings.base_url}/trainees/#{trainee.slug}",
      icon_emoji: ":this-is-fine:",
      username: "Register Trainee Teachers: Job Failure",
    )
  end
end
