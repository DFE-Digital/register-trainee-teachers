# frozen_string_literal: true

require "csv"

class AddEthnicityToBestPracticeNetwork < ActiveRecord::Migration[7.1]
  def up
    Service.new.call
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  class Service
    def call
      return unless upload

      upload.file.download do |csv|
        CSV.parse(csv, headers: true) do |row|
          trainee_id = row["trainee_id"]
          ethnicity = row["ethnicity"]
          trainee = provider.where(trainee_id:).first

          next unless trainee

          update_trainee(trainee, ethnicity)
        end
      end
    end

  private

    def upload
      @_upload ||= Upload.find_by_name("bpn-ethnicity.csv")
    end

    # Best Practice Network
    def provider
      @_provider ||= Provider.find_by(code: "6B1").trainees
    end

    def update_trainee(trainee, ethnicity)
      ethnicity_split = ethnicity.split(":").map(&:strip)

      ethnic_background = ::Hesa::CodeSets::Ethnicities::NAME_MAPPING[ethnicity_split.first]
      ethnic_group = ::Diversities::BACKGROUNDS.select { |_key, values| values.include?(ethnic_background) }.keys.first
      additional_ethnic_background = ethnicity_split.last

      trainee.update(
        ethnic_group:,
        ethnic_background:,
        additional_ethnic_background:,
      )
    end
  end
end
