require "rails_helper"

RSpec.describe TraineePreviousEducation do
  let(:trainee) { build(:trainee) }

  subject { described_class.new(trainee) }

  it "returns presented data" do
    expect(subject.call).to eql({
      "First A level subject and grade" => "#{trainee.a_level_1_subject} - #{trainee.a_level_1_grade}",
      "Second A level subject and grade" => "#{trainee.a_level_2_subject} - #{trainee.a_level_2_grade}",
      "Third A level subject and grade" => "#{trainee.a_level_3_subject} - #{trainee.a_level_3_grade}",
      "Undergraduate degree" => "Software Engineering",
      "Class of undergraduate degree" => "2:1",
      "Knowledge enhancement?" => "SKE not required",
      "Previously gained QTS" => "No",
    })
  end
end
