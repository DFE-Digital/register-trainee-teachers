# frozen_string_literal: true

require "rails_helper"
require Rails.root.join("db/data/20231220151357_add_other_degree_grade_to_teach_first_trainees.rb")

describe AddOtherDegreeGradeToTeachFirstTrainees::Service do
  let(:teach_first_provider) { create(:provider, :teach_first) }
  let(:degree) { create(:degree) }
  let(:trainee) { create(:trainee, provider: teach_first_provider, degrees: [degree]) }
  let(:grade) { "Other: Diploma of Higher Education" }
  let(:service) { described_class.new }

  before do
    allow(service).to receive(:entries).and_return([[trainee.provider_trainee_id, grade]])
    service.call
  end

  it "updates the trainee with the correct grade" do
    expect(trainee.degrees.first.reload.other_grade).to eql "Diploma of Higher Education"
    expect(trainee.degrees.first.grade).to eql "Other"
  end
end
