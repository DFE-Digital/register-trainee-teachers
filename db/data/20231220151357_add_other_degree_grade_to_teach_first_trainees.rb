# frozen_string_literal: true

class AddOtherDegreeGradeToTeachFirstTrainees < ActiveRecord::Migration[7.1]
  def up
    Service.new.call
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  class Service
    def call
      entries.each do |trainee_id, grade|
        trainee = teach_first_trainees.where(trainee_id:).first

        next unless trainee

        degree = trainee.degrees.first

        next unless degree

        update_degree(degree, grade)
      end
    end

  private

    def update_degree(degree, grade)
      other_grade = grade.split("Other:").last.strip

      degree.update(grade: "Other", other_grade: other_grade)
    end

    def teach_first_trainees
      @_teach_first_trainees ||= Provider.find_by(code: Provider::TEACH_FIRST_PROVIDER_CODE).trainees
    end

    def entries
      @entries ||= [
        ["0034K00000jkU7BQAU", "Other: Estimated 2.1/2.2 (Open university has a different way of assessing results and it is very hard to estimate)"],
        ["0034K00000itEmUQAU", "Other: 1st or 2:1"],
        ["0038e0000092mfVAAQ", "Other: Expected 1st"],
        ["0038e000009stlzAAA", "Other: second class Honours (2nd Division) (Top up based on master degree)"],
        ["0038e00000CuixpAAB", "Other: Pass"],
        ["0038e00000CuTnvAAF", "Other: Diploma of Higher Education"],
        ["0038e00000DfJEoAAN", "Other: General"],
        ["0038e00000939CtAAI", "Other: Merit"],
        ["0038e000009384yAAA", "Other: Distinction"],
      ]
    end
  end
end
