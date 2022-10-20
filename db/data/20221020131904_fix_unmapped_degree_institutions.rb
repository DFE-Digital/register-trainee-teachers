# frozen_string_literal: true

class FixUnmappedDegreeInstitutions < ActiveRecord::Migration[6.1]
  def up
    {
      "22100008860000214" =>
       [{ graduation_date: "2021-06-01",
          degree_type: "051",
          subject: "100062",
          institution: "0045",
          grade: "01",
          country: nil }],
      "1810518116453" =>
       [{ graduation_date: "2021-06-06",
          degree_type: "051",
          subject: "100318",
          institution: "1154",
          grade: "02",
          country: nil }],
      "22100078020000260" =>
       [{ graduation_date: "1991-07-01",
          degree_type: "051",
          subject: "100059",
          institution: "1172",
          grade: "02",
          country: nil }],
      "22100077765162301" =>
       [{ graduation_date: "2021-01-01",
          degree_type: "051",
          subject: "100051",
          institution: "0045",
          grade: "98",
          country: nil }],
      "22100038616545845" =>
       [{ graduation_date: "2022-07-05",
          degree_type: "083",
          subject: "100095",
          institution: "1096",
          grade: "03",
          country: nil }],
      "18100071401194353" =>
       [{ graduation_date: "2018-07-06",
          degree_type: "005",
          subject: "100391",
          institution: "1169",
          grade: "99",
          country: nil }],
      "22100077130003923" =>
       [{ graduation_date: "2022-06-28",
          degree_type: "051",
          subject: "100459",
          institution: "1001",
          grade: "02",
          country: nil }],
      "22100077130004528" =>
       [{ graduation_date: "2022-06-01",
          degree_type: "051",
          subject: "100459",
          institution: "1001",
          grade: "02",
          country: nil }],
      "22100068405091262" =>
       [{ graduation_date: "2022-07-01",
          degree_type: "051",
          subject: "100459",
          institution: "1050",
          grade: "02",
          country: nil }],
      "22100036780000238" =>
       [{ graduation_date: "2011-08-23",
          degree_type: "200",
          subject: "100513",
          institution: "0133",
          grade: "14",
          country: nil }],
      "22100057900001348" =>
       [{ graduation_date: "2022-06-22",
          degree_type: "051",
          subject: "100654",
          institution: "1001",
          grade: "01",
          country: nil }],
      "22100078430003116" =>
       [{ graduation_date: "2014-09-08",
          degree_type: "051",
          subject: "100070",
          institution: "0182",
          grade: "02",
          country: nil }],
      "22100078430003725" =>
       [{ graduation_date: "2021-06-01",
          degree_type: "083",
          subject: "100497",
          institution: "1071",
          grade: "03",
          country: nil }],
      "22100078430001994" =>
       [{ graduation_date: "2021-07-01",
          degree_type: "051",
          subject: "100070",
          institution: "0182",
          grade: "02",
          country: nil }],
      "22100071545032316" =>
       [{ graduation_date: "2020-01-01",
          degree_type: "402",
          subject: "100459",
          institution: "1153",
          grade: "14",
          country: nil }],
      "22100012820000017" =>
       [{ graduation_date: "2020-07-01",
          degree_type: "400",
          subject: "100433",
          institution: "1082",
          grade: "02",
          country: nil }],
      "22100078480005894" =>
       [{ graduation_date: "2022-07-01",
          degree_type: "051",
          subject: "100463",
          institution: "1050",
          grade: "01",
          country: nil }],
      "22100071390001691" =>
       [{ graduation_date: "2011-07-05",
          degree_type: "051",
          subject: "100059",
          institution: "0186",
          grade: "02",
          country: nil }],
      "22100078020001234" =>
       [{ graduation_date: "2022-07-01",
          degree_type: "051",
          subject: "100457",
          institution: "1124",
          grade: "01",
          country: nil }],
      "22100008860003031" =>
       [{ graduation_date: "2002-06-01",
          degree_type: "051",
          subject: "100078",
          institution: "1082",
          grade: "02",
          country: nil }],
      "1910518402973" =>
       [{ graduation_date: "2022-03-24",
          degree_type: "401",
          subject: "100271",
          institution: "7006",
          grade: "12",
          country: nil }],
      "22100078480004392" =>
       [{ graduation_date: "2007-07-01",
          degree_type: "083",
          subject: "100131",
          institution: "0186",
          grade: "03",
          country: nil }],
      "22100039560000044" =>
       [{ graduation_date: "2022-06-22",
          degree_type: "051",
          subject: "100457",
          institution: "1139",
          grade: "02",
          country: nil }],
      "22100008860000616" =>
       [{ graduation_date: "2005-09-01",
          degree_type: "401",
          subject: "100070",
          institution: "0182",
          grade: "12",
          country: nil }],
      "22100071390003732" =>
       [{ graduation_date: "2014-07-10",
          degree_type: "051",
          subject: "100063",
          institution: "0186",
          grade: "05",
          country: nil }],
    }.each do |hesa_id, hesa_degrees|
      trainee = Trainee.find_by(hesa_id: hesa_id)

      next unless trainee

      Degree.without_auditing do
        trainee.degrees.delete_all
        Degrees::CreateFromHesa.call(trainee: trainee, hesa_degrees: hesa_degrees)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
