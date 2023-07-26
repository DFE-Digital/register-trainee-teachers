# frozen_string_literal: true

module RegisterConsole
  def start
    show_warning_message_about_environments

    if Rails.env.development?
      super
    else
      puts("Hello! Who are you? This name will be used in the audit log for any changes you make.")
      who_are_you = $stdin.gets
      audited_user = "#{who_are_you.chomp} via the Rails console"
      puts("Any updates to models will be attributed in the audit logs to #{audited_user.inspect}")

      Audited.audit_class.as_user(audited_user) do
        super
      end
    end
  end

  def show_warning_message_about_environments
    if Rails.env.production?
      puts(("*" * 50).red)
      puts("** You are in the Rails console for PRODUCTION! **".red)
      puts(("*" * 50).red)
    else
      puts(("-" * 65).blue)
      puts("-- This is the Rails console for the #{environment_name} environment. --".blue)
      puts(("-" * 65).blue)
    end
  end

  def environment_name
    Rails.env
  end
end

if defined?(Rails::Console)
  Rails::Console.prepend(RegisterConsole)
end
