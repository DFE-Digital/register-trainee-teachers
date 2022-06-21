# frozen_string_literal: true

require "rails_helper"

RSpec.feature "dfe analytics integration" do
  include TraineeHelper

  context "clicking return to draft record later" do
    scenario "sends dfe analytics events" do
      given_the_send_to_big_query_feature_is_enabled
      and_i_am_authenticated
      when_i_visit_the_trainee_index_page
      then_dfe_analytics_events_are_sent
    end
  end

private

  def given_the_send_to_big_query_feature_is_enabled
    enable_features("google.send_data_to_big_query")
  end

  def and_i_am_authenticated
    given_i_am_authenticated
  end

  def when_i_visit_the_trainee_index_page
    trainee_index_page.load
  end

  def then_dfe_analytics_events_are_sent
    expect(%i[web_request create_entity]).to have_been_enqueued_as_analytics_events
  end
end
