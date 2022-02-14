# frozen_string_literal: true

module Dttp
  module CodeSets
    module AcademicYears
      ACADEMIC_YEAR_2008_2009_FIRST = "1757b5c4-2bd1-e711-80df-005056ac45bb"
      ACADEMIC_YEAR_2008_2009_SECOND = "77f80620-680f-ea11-a811-000d3ab5d037"
      ACADEMIC_YEAR_2019_2020 = "00469dd9-bc46-e711-80c8-0050568902d3"
      ACADEMIC_YEAR_2020_2021 = "76bcaeca-2bd1-e711-80df-005056ac45bb"
      ACADEMIC_YEAR_2021_2022 = "21196925-17b9-e911-a863-000d3ab0dc71"
      ACADEMIC_YEAR_2022_2023 = "ed0db9f4-eff5-eb11-94ef-000d3ab1e900"

      MAPPING = {
        "1996/97" => { entity_id: "63fc6019-2cd1-e711-80df-005056ac45bb" },
        "1997/98" => { entity_id: "64fc6019-2cd1-e711-80df-005056ac45bb" },
        "1998/99" => { entity_id: "0d57b5c4-2bd1-e711-80df-005056ac45bb" },
        "1999/00" => { entity_id: "0e57b5c4-2bd1-e711-80df-005056ac45bb" },
        "2000/01" => { entity_id: "0f57b5c4-2bd1-e711-80df-005056ac45bb" },
        "2001/02" => { entity_id: "1057b5c4-2bd1-e711-80df-005056ac45bb" },
        "2002/03" => { entity_id: "1157b5c4-2bd1-e711-80df-005056ac45bb" },
        "2003/04" => { entity_id: "1257b5c4-2bd1-e711-80df-005056ac45bb" },
        "2004/05" => { entity_id: "1357b5c4-2bd1-e711-80df-005056ac45bb" },
        "2005/06" => { entity_id: "1457b5c4-2bd1-e711-80df-005056ac45bb" },
        "2006/07" => { entity_id: "1557b5c4-2bd1-e711-80df-005056ac45bb" },
        "2007/08" => { entity_id: "1657b5c4-2bd1-e711-80df-005056ac45bb" },
        "2008/09" => { entity_id: ACADEMIC_YEAR_2008_2009_FIRST },
        "2008/09 (DUPE)" => { entity_id: ACADEMIC_YEAR_2008_2009_SECOND },
        "2009/10" => { entity_id: "71bcaeca-2bd1-e711-80df-005056ac45bb" },
        "2010/11" => { entity_id: "72bcaeca-2bd1-e711-80df-005056ac45bb" },
        "2011/12" => { entity_id: "73bcaeca-2bd1-e711-80df-005056ac45bb" },
        "2012/13" => { entity_id: "74bcaeca-2bd1-e711-80df-005056ac45bb" },
        "2013/14" => { entity_id: "75bcaeca-2bd1-e711-80df-005056ac45bb" },
        "2014/15" => { entity_id: "dc4fe179-bc46-e711-80c8-0050568902d3" },
        "2015/16" => { entity_id: "e5694d69-bc46-e711-80c8-0050568902d3" },
        "2016/17" => { entity_id: "22320514-b646-e711-80c8-0050568902d3" },
        "2017/18" => { entity_id: "8289012b-2487-e711-80e7-3863bb3640b8" },
        "2018/19" => { entity_id: "0f8ee3cd-bc46-e711-80c8-0050568902d3" },
        "2019/20" => { entity_id: ACADEMIC_YEAR_2019_2020 },
        "2020/21" => { entity_id: ACADEMIC_YEAR_2020_2021 },
        "2021/22" => { entity_id: ACADEMIC_YEAR_2021_2022 },
        "2022/23" => { entity_id: ACADEMIC_YEAR_2022_2023 },
      }.freeze
    end
  end
end
