module EthnicGroupsHelper
  def format_ethnic_group_options(options)
    options.reject { |option| option == Diversities::ENUMS[:not_provided] }
  end

  def other_ethnic_background_option?(ethnic_background)
    ethnic_background.include?("Another") && ethnic_background.include?("background")
  end
end
