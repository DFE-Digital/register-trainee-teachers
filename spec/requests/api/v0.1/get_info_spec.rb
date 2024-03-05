# frozen_string_literal: true

require "rails_helper"

describe "`GET /info` endpoint" do
  it_behaves_like "a register API endpoint", "/api/v0.1/info"
end
