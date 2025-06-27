# frozen_string_literal: true

require "govuk_tech_docs"
require_relative "lib/govuk_tech_docs/path_helpers"
require_relative "lib/govuk_tech_docs/contribution_banner"

GovukTechDocs.configure(self, livereload: { host: "0.0.0.0" })

set :relative_links, true

activate :relative_assets

configure :build do
  activate :asset_hash
  activate :minify_css
  activate :minify_html
end
