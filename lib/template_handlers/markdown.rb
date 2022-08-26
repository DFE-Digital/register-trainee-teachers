# frozen_string_literal: true

module TemplateHandlers
  class Markdown
    class << self
      def call(_template, source)
        parsed = FrontMatterParser::Parser.new(:md).call(source)

        front_matter = parsed.front_matter
        html = render(parsed.content)

        "@front_matter = #{front_matter.inspect}; #{html.inspect}.html_safe;"
      end

      def render(text)
        GovukMarkdown.render(text).html_safe
      end
    end
  end
end
