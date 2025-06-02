require "govuk_tech_docs"

GovukTechDocs.configure(self)

set :relative_links, true

activate :relative_assets
activate :asset_hash

configure :build do
  activate :minify_css
  activate :minify_html
end
