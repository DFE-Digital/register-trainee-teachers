# frozen_string_literal: true

module ActivityTracker
  def track_activity
    Activity.track(
      user: current_user,
      controller_name: controller_name,
      action_name: action_name,
      metadata: params.permit!.to_h,
    )
  end
end
