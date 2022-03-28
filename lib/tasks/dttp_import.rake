# frozen_string_literal: true

namespace :dttp do
  desc "imports trainees by their dttp_ids in a predefined csv"
  task import: [:environment] do
    csv = CSV.read("data/dttp-trainees-without-academic-years.csv", headers: true)

    dttp_ids = csv.map { |x| x["contact_dttp_id"] }.uniq
    dttp_trainees = Dttp::Trainee.where(dttp_id: dttp_ids)
    dttp_trainees.importable.find_each do |dttp_trainee|
      Trainees::CreateFromDttpJob.perform_later(dttp_trainee)
    end
  end
end
