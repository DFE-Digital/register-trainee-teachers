# frozen_string_literal: true

require "govuk_tech_docs"

require "config/environment"

require "lib/govuk_tech_docs/path_helpers"
require "lib/govuk_tech_docs/contribution_banner"
require "services/bulk_update/add_trainees/config"

GovukTechDocs.configure(self, livereload: { host: "0.0.0.0" })

set :relative_links, true
set :markdown_engine, :kramdown

activate :relative_assets

configure :build do
  activate :asset_hash
  activate :minify_css
  activate :minify_html
end
