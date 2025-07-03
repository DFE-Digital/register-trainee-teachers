# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::AppendMetadata do
  subject { described_class }

  it { is_expected.to include ServicePattern }

  describe "#call" do
    let(:trainees) { Trainee.includes(%i[provider degrees hesa_trainee_detail published_course employing_school lead_partner nationalities withdrawal_reasons]).page(1).per(25) }
    let(:serializer_klass) { Api::V20250Rc::TraineeSerializer }

    before { create_list(:trainee, 2, :with_hesa_trainee_detail) }

    it do
      expect(
        described_class.call(objects: trainees, serializer_klass: serializer_klass),
      ).to eq(
        data: trainees.map { |trainee| Api::V20250Rc::TraineeSerializer.new(trainee).as_hash },
        meta: {
          current_page: trainees.current_page,
          total_pages: trainees.total_pages,
          total_count: trainees.total_count,
          per_page: trainees.limit_value,
        },
      )
    end
  end
end
