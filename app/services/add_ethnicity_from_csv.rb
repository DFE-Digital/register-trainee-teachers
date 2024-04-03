# frozen_string_literal: true

class AddEthnicityFromCsv
  def initialize(file_name:, provider_code:)
    @upload = Upload.find_by_name(file_name)
    @provider = Provider.find_by_code(provider_code)
  end

  def call
    return unless upload && provider

    upload.file.download do |csv|
      CSV.parse(csv, headers: true) do |row|
        provider_trainee_id = row["provider_trainee_id"]
        ethnicity = row["ethnicity"]
        trainee = provider.trainees.where(provider_trainee_id:).first

        next unless trainee

        update_trainee(trainee, ethnicity)
      end
    end
  end

private

  attr_reader :upload, :provider

  def update_trainee(trainee, ethnicity)
    ethnicity_split = ethnicity.split(":").map(&:strip)

    ethnic_background = ::Hesa::CodeSets::Ethnicities::NAME_MAPPING[ethnicity_split.first]
    ethnic_group = ::Diversities::BACKGROUNDS.select { |_key, values| values.include?(ethnic_background) }.keys.first
    additional_ethnic_background = ethnicity_split.length == 1 ? nil : ethnicity_split.last
    diversity_disclosure = ["Prefer not to say", "Not available"].include?(ethnic_background) ? :diversity_not_disclosed : :diversity_disclosed

    trainee.update(
      ethnic_group:,
      ethnic_background:,
      additional_ethnic_background:,
      diversity_disclosure:,
    )
  end
end
