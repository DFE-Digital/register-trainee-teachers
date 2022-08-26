# frozen_string_literal: true

require "template_handlers/markdown"

ActionView::Template.register_template_handler(:md, TemplateHandlers::Markdown)
