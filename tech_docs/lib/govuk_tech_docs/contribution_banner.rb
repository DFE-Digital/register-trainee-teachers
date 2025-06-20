# frozen_string_literal: true

# Patched from: https://github.com/alphagov/tech-docs-gem/blob/v4.4.0/lib/govuk_tech_docs/contribution_banner.rb
# Changed lines: L64-66, L68-70, L77-79

module GovukTechDocs
  # Helper included
  module ContributionBanner
    def source_urls
      SourceUrls.new(current_page, config)
    end
  end

  class SourceUrls
    attr_reader :current_page, :config

    def initialize(current_page, config)
      @current_page = current_page
      @config = config
    end

    def view_source_url
      override_from_page || source_from_yaml_file || source_from_file
    end

    def report_issue_url
      url = config[:source_urls]&.[](:report_issue_url)
      params = {
        body: "Problem with '#{current_page.data.title}' (#{config[:tech_docs][:host]}#{current_page.url})",
      }

      if url.nil?
        url = "#{repo_url}/issues/new"
        params["labels"] = "bug"
        params["title"] = "Re: '#{current_page.data.title}'"
      else
        params["subject"] = "Re: '#{current_page.data.title}'"
      end
      "#{url}?#{URI.encode_www_form(params)}"
    end

    def repo_url
      "https://github.com/#{config[:tech_docs][:github_repo]}"
    end

    def repo_branch
      config[:tech_docs][:github_branch] || "master" # TODO: change this to 'main' in a future breaking release
    end

  private

    # If a `page` local exists, see if it has a `source_url`. This is used by the
    # pages that are created by the proxy system because they can't use frontmatter
    def override_from_page
      locals.key?(:page) ? locals[:page].try(:source_url) : false
    end

    # In the frontmatter we can specify a `source_url`. Use this if the actual
    # source of the page is in another GitHub repo.
    def source_from_yaml_file
      current_page.data.source_url
    end

    # As the last fallback link to the source file in this repository.
    def source_from_file
      # Set the View source link based on the documentation type: [api-docs, csv-docs]
      #
      if build_dir == "build"
        "#{repo_url}/blob/#{repo_branch}/source/#{current_page.file_descriptor[:relative_path]}"
      else
        "#{repo_url}/blob/#{repo_branch}/source/#{build_dir.split('/').last}/#{current_page.file_descriptor[:relative_path]}"
      end
    end

    def locals
      current_page.metadata[:locals]
    end

    def build_dir
      config[:build_dir]
    end
  end
end
