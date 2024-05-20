require 'rails_helper'
require 'rake'

describe 'cleanup:discard_trainees' do
  before :all do
    Rake.application.rake_require "tasks/cleanup"
    Rake::Task.define_task(:environment)
  end

  let(:run_rake_task) do
    Rake::Task['cleanup:discard_trainees'].reenable
    Rake.application.invoke_task "cleanup:discard_trainees[#{file_path}]"
  end

  context 'when file path is provided' do
    let(:file_path) { Rails.root.join('spec', 'fixtures', 'files', 'cleanup_emails.txt') }
    let(:emails) { File.readlines(file_path).map(&:chomp) }

    before do
      emails.each { |email| create(:trainee, email: email) }
    end

    it 'destroys the trainees with emails in the file' do
      expect { run_rake_task }.to change { Trainee.discarded.count }.by(emails.count)
    end
  end

  context 'when file path is not provided' do
    let(:file_path) { '' }

    it 'raises an error' do
      expect { run_rake_task }.to raise_error(RuntimeError, 'You must provide a file path')
    end
  end
end
