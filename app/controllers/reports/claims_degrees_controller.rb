# frozen_string_literal: true

module Reports
  class ClaimsDegreesController < ApplicationController
    before_action :authorize_user

    DATE_FIELD_MAPPING = {
      "from_date(3i)" => "from_day",
      "from_date(2i)" => "from_month",
      "from_date(1i)" => "from_year",
      "to_date(3i)" => "to_day",
      "to_date(2i)" => "to_month",
      "to_date(1i)" => "to_year",
    }.freeze

    def index
      @form = ClaimsDegreesForm.new(form_params)

      if form_params.present? && @form.valid?
        authorize(:trainee, :export?)

        headers["X-Accel-Buffering"] = "no"
        headers["Cache-Control"] = "no-cache"
        headers["Content-Type"] = "text/csv; charset=utf-8"
        headers["Content-Disposition"] = %(attachment; filename="#{claims_degrees_filename}")
        headers["Last-Modified"] = Time.zone.now.ctime.to_s

        response.status = 200
        render(plain: Exports::ClaimsDegreeExport.call(@form.degrees_scope))
      else
        render(:index)
      end
    end

  private

    def authorize_user
      redirect_to(root_path) unless current_user.system_admin?
    end

    def form_params
      return {} if params[:reports_claims_degrees_form].blank?

      params.require(:reports_claims_degrees_form)
            .permit(*DATE_FIELD_MAPPING.keys)
            .transform_keys do |key|
              DATE_FIELD_MAPPING[key] || key
            end
    end

    def claims_degrees_filename
      date_range = ""
      date_range += "_from_#{@form.from_date_parsed.iso8601}" if @form.from_date_parsed
      date_range += "_to_#{@form.to_date_parsed.iso8601}" if @form.to_date_parsed

      "trainee_degrees#{date_range}_#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.csv"
    end
  end
end
