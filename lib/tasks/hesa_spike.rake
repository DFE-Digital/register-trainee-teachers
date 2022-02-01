# frozen_string_literal: true
#
require "mechanize"

namespace :hesa do
  desc <<~DESC
    Authenticate and retrieve a data collection as XML
  DESC

  task get_collection: :environment do
    username = ENV["EMAIL"]
    password = ENV["PASSWORD"]

    auth_url = "https://identity.hesa.ac.uk/Account/RemoteLogOn?ReturnDomain=https://datacollection.hesa.ac.uk&ReturnUrl=%2f"
    example_xml_url = "https://datacollection.hesa.ac.uk/apis/itt/1.1/TRNData/c21053/Latest/Test"

    agent = Mechanize.new
    agent.get(auth_url) do |page|
      page.form_with(id: "loginForm") do |login_form|
        login_form.EmailAddress = username
        login_form.Password = password
      end.submit

      # TODO check response
    end

    agent.get(example_xml_url) do |page|
      puts page.body
    end
  end
end
