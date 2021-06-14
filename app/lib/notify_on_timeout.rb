# frozen_string_literal: true

module NotifyOnTimeout
  def send_message_to_slack(trainee, class_name)
    SlackNotifierService.call(message: "#{class_name} for Trainee id: #{trainee.id} has timed out after #{Settings.jobs.max_poll_duration_days} days.",
                              icon_emoji: ":this-is-fine:", username: "Register Trainee Teachers: Job Failure")
  end
end
