# frozen_string_literal: true

module NotifyOnTimeout
  def notify_on_timeout(trainee, class_name)
    TeamsNotifierService.call(
      title: "#{class_name} timed out",
      message: "#{class_name} for Trainee with slug: #{trainee.slug} has timed out after #{Settings.jobs.max_poll_duration_days} days.\n\n
        [Check the trainee record](#{Settings.base_url}/trainees/#{trainee.slug})\n\n
        [Check the pending TRNs](#{Settings.base_url}/system-admin/pending_trns)",
      icon_emoji: "⏳",
    )
  end
end
