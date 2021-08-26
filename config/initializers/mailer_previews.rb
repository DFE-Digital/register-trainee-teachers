# frozen_string_literal: true

ActiveSupport.on_load(:action_controller, run_once: true) do
  Rails::MailersController.prepend(RegisterMailersController)
end
