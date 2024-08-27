# frozen_string_literal: true

class SetHesaTestRecords
  include ServicePattern

  def call
    clear_trainees!
    create_trainees!
    update_trns!
  end

private

  def clear_trainees!
    clear_trainee(george)
    clear_trainee(ringo)
    clear_trainee(john)
  end

  def clear_trainee(trainee)
    Trainee.find_by(slug: trainee[:slug])&.destroy
  end

  def create_trainees!
    create_trainee(george)
    create_trainee(ringo)
    create_trainee(john)
  end

  def create_trainee(trainee)
    Trainees::CreateFromHesa.call(
      hesa_trainee: trainee[:hesa],
      record_source: "hesa_collection",
      skip_background_jobs: true,
      slug: trainee[:slug],
    )
  end

  def update_trns!
    update_trn(george)
    update_trn(ringo)
    update_trn(john)
  end

  def update_trn(trainee)
    trainee_record = Trainee.find_by(slug: trainee[:slug])
    trainee_record.update_column(:trn, trainee[:trn])
    trainee_record.update_column(:state, :trn_received)
  end

  def george
    {
      trn: "3001586",
      slug: "4RwkB5YADdBbAVMcLJ8cgSaL",
      hesa: {
        first_names: "George",
        last_name: "Harrison",
        date_of_birth: "01/01/1950",
        sex: "11",
        hesa_id: "12121212121212121",
        study_mode: "01",
        ukprn: "10007140",
        itt_aim: "202",
        itt_qualification_aim: "020",
        training_route: "12",
        itt_start_date: "01/09/2021",
        itt_end_date: "01/07/2024",
        course_age_range: "13918",
        course_subject_one: "100366",
      },
    }
  end

  def ringo
    {
      trn: "3001587",
      slug: "Bcyx6hB4kd9AxRtK3jYdkTEo",
      hesa: {
        first_names: "Ringo",
        last_name: "Starr",
        date_of_birth: "01/01/1955",
        sex: "11",
        hesa_id: "13131313131313131",
        study_mode: "01",
        ukprn: "10007140",
        itt_aim: "202",
        itt_qualification_aim: "020",
        training_route: "11",
        itt_start_date: "01/09/2021",
        itt_end_date: "01/07/2024",
        course_age_range: "13918",
        course_subject_one: "100403",
      },
    }
  end

  def john
    {
      trn: "3001588",
      slug: "6wk4nGs8BnLtvgniu593uHau",
      hesa: {
        first_names: "John",
        last_name: "Lennon",
        date_of_birth: "01/01/1960",
        sex: "11",
        hesa_id: "14141414141414141",
        study_mode: "01",
        ukprn: "10007140",
        itt_aim: "202",
        itt_qualification_aim: "020",
        training_route: "12",
        itt_start_date: "01/09/2022",
        itt_end_date: "01/07/2025",
        course_age_range: "13918",
        course_subject_one: "100409",
      },
    }
  end
end
