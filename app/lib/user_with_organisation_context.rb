class UserWithOrganisationContext
  def initialize(user:, session:)
    @user = user
    @session = session
  end

  def organisation
    @current_organisation ||= if has_multiple_organisations?
                                return unless session[:current_organisation].present?

                                get_organisation
                              else
                                user.providers.first || user.provider # TODO last bit just until we migrate all user provider relationships
                              end
  end

  def lead_school?
    organisation.is_a?(School)
  end

  def provider?
    organisation.is_a?(Provider)
  end

  def has_multiple_organisations?
    user.lead_schools.any? || user.providers.count > 1
  end

  attr_reader :user

private

  attr_reader :session

  def organisation_class
    session[:current_organisation][:type] == "School" ? School : Provider
  end

  def organisation_id
    session[:current_organisation][:id]
  end

  def get_organisation
    organisation_to_return = if organisation_class == Provider
                               user.providers.find_by(id: organisation_id)
                             else
                               user.lead_schools.find_by(id: organisation_id)
                             end
    raise Pundit::NotAuthorizedError if organisation_to_return.nil?
    organisation_to_return
  end

  def method_missing(method, *args)
    return user.send(method, *args) if user.respond_to?(method)
    super
  end
end
