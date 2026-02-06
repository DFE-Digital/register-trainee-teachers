# frozen_string_literal: true

require "govuk_tech_docs"

require "config/environment"

require "lib/govuk_tech_docs/path_helpers"
require "lib/govuk_tech_docs/contribution_banner"
require "services/bulk_update/add_trainees/config"

GovukTechDocs.configure(self, livereload: { host: "0.0.0.0" })

TECH_DOCS_CONFIG = YAML.load_file(File.expand_path("config/tech-docs.yml", __dir__))

helpers do
  def preview_warning_if_needed
    version = current_page.path.match(%r{v\d{4}\.\d})&.[](0)
    return unless version && TECH_DOCS_CONFIG.fetch("preview_versions", []).include?(version)

    partial("partials/preview_warning", locals: { version: })
  end
end

set :relative_links, true
set :markdown_engine, :kramdown

activate :relative_assets

configure :build do
  activate :asset_hash
  activate :minify_css
  activate :minify_html
end
