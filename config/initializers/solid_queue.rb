# frozen_string_literal: true

SolidQueue.on_start { RailsSemanticLogger.add_server_appenders }
