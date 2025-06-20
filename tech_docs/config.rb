# frozen_string_literal: true

require "govuk_tech_docs"
require "config/environment"

require "lib/govuk_tech_docs/path_helpers"
require "lib/govuk_tech_docs/contribution_banner"
require "services/bulk_update/add_trainees/config"

GovukTechDocs.configure(self, livereload: { host: "0.0.0.0" })

set :relative_links, true

activate :relative_assets

configure :build do
  activate :asset_hash
  activate :minify_css
  activate :minify_html
end

helpers do
  def csv_fields
    @csv_fields ||= YAML.load_file(
      File.expand_path("../app/views/bulk_update/add_trainees/reference_docs/fields.yaml", __dir__)
    )
  end
end
