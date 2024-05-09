require 'rails_helper'
require 'rake'

RSpec.describe 'verify:record_sources' do
  before do
    Rails.application.load_tasks
  end

  it 'runs without errors' do
    expect { Rake::Task['verify:record_sources'].invoke }.not_to raise_error
  end

  it 'prints the expected output' do
    trainee1 = FactoryBot.create(:trainee, :record_source_dttp, :created_from_dttp)
    trainee2 = FactoryBot.create(:trainee, :record_source_hesa_collection, hesa_id: '123')
    trainee3 = FactoryBot.create(:trainee, :record_source_manual, apply_application_id: nil, created_from_dttp: false, hesa_id: nil)

    expect { Rake::Task['verify:record_sources'].invoke }.to output(
      a_string_including("Progress: 33.33%", "Progress: 66.67%", "Progress: 100.0%", "Mismatch counts:")
    ).to_stdout
  end
end
