# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.1"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )

# govuk-frontend related assets
Rails.application.config.assets.paths << Rails.root.join("node_modules/govuk-frontend/dist/govuk/assets/rebrand/images")
Rails.application.config.assets.paths << Rails.root.join("node_modules/govuk-frontend/dist/govuk/assets/fonts")
Rails.application.config.assets.paths << Rails.root.join("node_modules/govuk-frontend/dist/govuk/assets")

# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join("node_modules")

# GOVUK Deps
Rails.application.config.assets.precompile += %w[
  accessible-autocomplete/dist/accessible-autocomplete.min.css
]
