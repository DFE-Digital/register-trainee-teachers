# frozen_string_literal: true

module ReferenceData
  class DownloadsController < ApplicationController
    skip_before_action :authenticate

    def show
      send_data(
        data.as_csv,
        filename: filename,
        format: :csv,
        disposition: :attachment
      )
    end

    private

    def data
      @data ||= data_klass.find(
        params[:reference_datum_attribute]
      )
    end

    def filename
      "#{params[:reference_datum_attribute].gsub('_', '-')}-#{params[:reference_data_version]}.csv"
    end

    def version
      params[:reference_data_version].titleize.gsub(/\.|\s/, "")
    end

    def data_klass
      "Hesa::ReferenceData::#{version}".constantize
    end
  end
end
