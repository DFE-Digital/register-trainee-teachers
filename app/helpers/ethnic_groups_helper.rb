module EthnicGroupsHelper
  def format_ethnic_group_options(options)
    options.reject { |option| option == "no_ethnicity_provided" }
  end
end
