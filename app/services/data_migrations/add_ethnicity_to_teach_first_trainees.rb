# frozen_string_literal: true

module DataMigrations
  class AddEthnicityToTeachFirstTrainees
    def call
      entries.each do |trainee_id, ethnicity|
        trainee = teach_first_trainees.where(trainee_id:).first

        next unless trainee

        update_trainee(trainee, ethnicity)
      end
    end

  private

    def teach_first_trainees
      Provider.find_by(code: Provider::TEACH_FIRST_PROVIDER_CODE).trainees
    end

    def update_trainee(trainee, ethnicity)
      ethnicity_split = ethnicity.split(":").map(&:strip)

      ethnic_background = ::Hesa::CodeSets::Ethnicities::NAME_MAPPING[ethnicity_split.first]
      ethnic_group = ::Diversities::BACKGROUNDS.select { |_key, values| values.include?(ethnic_background) }&.keys&.first
      additional_ethnic_background = ethnicity_split.last

      trainee.update(ethnic_group:, ethnic_background:, additional_ethnic_background:)
    end

    def entries
      [
        ["0034K00000aVaLfQAK", "Any other ethnic background: romanian"],
        ["0034K00000eBceTQAS", "Any other White background: Canadian Metis"],
        ["0034K00000hgkEzQAI", "Any other Black background: Filipino"],
        ["0034K00000jix2FQAQ", "Any other Black background: South East Asian"],
        ["0038e00000De27bAAB", "Any other Black background: Japanese"],
        ["0038e00000EZ2zNAAT", "Any other White background: Roma"],
        ["0038e00000FAXwUAAX", "Any other ethnic background: Latina"],
        ["0034K00000dh71yQAA", "Any other White background: British"],
        ["0034K00000fkBYsQAM", "Any other Black background: Parsi Zoroastrian"],
        ["0034K00000jjcwTQAQ", "Any other White background: Turkish"],
        ["0034K00000PeO4AQAV", "Any other Black background: British Mauritian"],
        ["0034K00000PeOByQAN", "Any other Asian background: BLACK AFRICAN"],
        ["0034K00000PfXruQAF", "Any other ethnic background: North African"],
        ["0034K00000aU95lQAC", "Any other White background: Swedish"],
        ["0034K00000crddlQAA", "Any other White background: British/ German"],
        ["0034K00000dhJRZQA2", "Any other ethnic background: Jewish"],
        ["0034K00000diXHmQAM", "Any other ethnic background: Turkish"],
        ["0034K00000eBaTUQA0", "Any other Asian background: Black British - African/Caribbean"],
        ["0034K00000eBHufQAG", "Any other ethnic background: Iranian"],
        ["0034K00000eBO2lQAG", "Any other Black background: Afghan"],
        ["0034K00000eCk63QAC", "Any other White background: Bosniak"],
        ["0034K00000eDLL9QAO", "Any other Black background: British Sri Lankan"],
        ["0034K00000eDZ6RQAW", "Any other White background: European"],
        ["0034K00000f1alKQAQ", "Any other Black background: Sri Lankan"],
        ["0034K00000fkpj5QAA", "Any other White background: Greek Cypriot"],
        ["0034K00000flHddQAE", "Any other White background: Turkish"],
        ["0034K00000flUTPQA2", "Any other Mixed or Multiple ethnic background: Pakistani, Indian and Caribbean"],
        ["0034K00000gLf2oQAC", "Any other Black background: Iranian"],
        ["0034K00000gOH9JQAW", "Any other Mixed or Multiple ethnic background: Moroccan and greek Cypriot"],
        ["0034K00000hDfhlQAC", "Any other White background: Jewish"],
        ["0034K00000hEjYGQA0", "Any other Black background: Sri Lankan"],
        ["0034K00000hFCfKQAW", "Any other Mixed or Multiple ethnic background: Mixed - White Irish, Black Caribbean, Asian Caribbean"],
        ["0034K00000hFQEzQAO", "Any other ethnic background: Greek Cypriot / Black Caribbean"],
        ["0034K00000hFx8kQAC", "Any other White background: Cypriot"],
        ["0034K00000hh3XkQAI", "Any other Black background: Iranian"],
        ["0034K00000hi0BQQAY", "Any other White background: Turkish"],
        ["0034K00000hjONAQA2", "Any other White background: Norwegian British"],
        ["0034K00000ipn3jQAA", "Any other Mixed or Multiple ethnic background: Chinese and Portuguese"],
        ["0034K00000iqQQ8QAM", "Any other ethnic background: Persian"],
        ["0034K00000istTMQAY", "Any other White background: Scandinavian"],
        ["0034K00000itgliQAA", "Any other Black background: Sri Lankan"],
        ["0034K00000jiK55QAE", "Any other ethnic background: North African"],
        ["0034K00000jjzv0QAA", "Any other White background: Albanian"],
        ["0034K00000jkBs9QAE", "Any other Asian background: Mauritian"],
        ["0034K00000Pea4nQAB", "Any other Black background: Afghan"],
        ["0034K00000PeatIQAR", "Any other White background: Eastern European Jewish"],
        ["0034K00000PebOCQAZ", "Any other Black background: Turkish"],
        ["0034K00000PedqYQAR", "Any other White background: White British/Italian"],
        ["0034K00000PedUkQAJ", "Any other White background: American"],
        ["0034K00000PeOE7QAN", "Any other Black background: Pakistani and Srilanka"],
        ["0034K00000PeR7PQAV", "Any other White background: American"],
        ["0034K00000PeRI2QAN", "Any other White background: Ashkenazi Jewish"],
        ["0034K00000PeRZfQAN", "Any other ethnic background: Turkish Cypriot"],
        ["0034K00000PeTFnQAN", "Any other Black background: Sri Lankan"],
        ["0034K00000PeZHCQA3", "Any other ethnic background: Iranian"],
        ["0034K00000PeZwGQAV", "Any other White background: Ethnic Albanian"],
        ["0034K00000PfFQEQA3", "Any other Asian background: Sudanese"],
        ["0034K00000Q18nsQAB", "Any other Black background: Sri Lankan"],
        ["0034K00000Z5m93QAB", "Any other Black background: Nepalease"],
        ["0038e000004cjqAAAQ", "Any other Black background: asian or asian british -Sri Lankan"],
        ["0038e000008DW0MAAW", "Any other White background: Jewish"],
        ["0038e000009rRHoAAM", "Any other Black background: Afghan"],
        ["0038e00000CuTnvAAF", "Any other ethnic background: Turkish/Kurdish"],
        ["0038e00000CuYPRAA3", "Any other White background: white and hispanic"],
        ["0038e00000CwEADAA3", "Any other Black background: Afghan"],
        ["0038e00000DdacNAAR", "Any other ethnic background: Moroccan/ North African"],
        ["0038e00000DgrIdAAJ", "Any other Black background: Mauritian"],
        ["0038e00000Dh64VAAR", "Any other Black background: Kurdish"],
        ["0038e00000DhHWlAAN", "Any other ethnic background: Mauritian"],
        ["0038e00000HG5DMAA1", "Any other ethnic background: African Asian"],
        ["0034K00000eAcrTQAS", "Any other Black background: Half Pakistani, Half Indian"],
        ["0034K00000eE0bxQAC", "Any other White background: British and Italian"],
        ["0038e000008DXmcAAG", "Any other White background: Greek Cypriot"],
        ["0038e00000CxFV0AAN", "Any other White background: Moroccan father. Mother is British but her parents were Croatian."],
        ["0034K00000di94iQAA", "Any other White background: Eastern European (Ashkenazi) Jewish"],
        ["0034K00000dihTKQAY", "Any other White background: Spanish/Irish/Hungarian"],
        ["0034K00000hFEy0QAG", "Any other Asian background: African Asian"],
        ["0034K00000hjWrFQAU", "Any other ethnic background: Kurdish"],
        ["0034K00000PeM53QAF", "Any other Black background: Asian British- Sri Lankan"],
        ["0034K00000dhcbrQAA", "Any other Black background: Sri Lankan"],
        ["0034K00000irvaDQAQ", "Any other Black background: Half Chinese Half Japanese"],
        ["0034K00000Peb4RQAR", "Any other Black background: Filipino"],
        ["0034K00000PfN71QAF", "Any other Mixed or Multiple ethnic background: Chinese and White British"],
        ["0038e00000CvC9kAAF", "Any other Black background: Sri Lankan"],
        ["0038e00000CvoqrAAB", "Any other Mixed or Multiple ethnic background: British father, Turkish mother"],
        ["0038e00000Dfn8TAAR", "Any other ethnic background: Egyptian"],
        ["0034K00000flYK4QAM", "Any other White background: South African"],
        ["0038e000009qhvCAAQ", "Any other ethnic background: Latin American"],
        ["0038e00000Fjfy2AAB", "Any other White background: South America"],
        ["0034K00000eDqexQAC", "Any other Mixed or Multiple ethnic background: White Turkish"],
        ["0034K00000eDTnRQAW", "Any other Black background: Sri Lankan"],
        ["0034K00000jjFNMQA2", "Any other Mixed or Multiple ethnic background: White and Latina"],
        ["0038e000008Dd8JAAS", "Any other White background: White South African and British"],
        ["0038e0000092hiiAAA", "Any other Mixed or Multiple ethnic background: Pakistan, Bangladesh"],
        ["0038e00000DfHToAAN", "Any other ethnic background: Moroccan"],
        ["0034K00000f0iPtQAI", "Any other White background: Greek and English"],
        ["0034K00000hj2RvQAI", "Any other White background: White - Jewish"],
        ["0034K00000irIKwQAM", "Any other Mixed or Multiple ethnic background: Asian (Bangladeshi), White English and Azeri (Turkish/Iranian)"],
        ["0034K00000itRfWQAU", "Any other White background: Hispanic"],
        ["0034K00000Peb9HQAR", "Any other White background: American"],
        ["0034K00000PebccQAB", "Any other Black background: Brown British"],
        ["0034K00000Z6drTQAR", "Any other Mixed or Multiple ethnic background: African American and American, white"],
      ]
    end
  end
end
