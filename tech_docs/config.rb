require "govuk_tech_docs"

GovukTechDocs.configure(self, livereload: { host: "0.0.0.0" })

set :relative_links, true

activate :relative_assets

configure :build do
  activate :asset_hash
  activate :minify_css
  activate :minify_html
end
