# frozen_string_literal: true

COMMENCEMENT_STATUS_ENUMS = {
  itt_started_on_time: "itt_started_on_time",
  itt_started_later: "itt_started_later",
  itt_not_yet_started: "itt_not_yet_started",
}.freeze

COMMENCEMENT_STATUSES = {
  COMMENCEMENT_STATUS_ENUMS[:itt_started_on_time] => 0,
  COMMENCEMENT_STATUS_ENUMS[:itt_started_later] => 1,
  COMMENCEMENT_STATUS_ENUMS[:itt_not_yet_started] => 2,
}.freeze
