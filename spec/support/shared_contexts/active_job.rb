RSpec.shared_context 'perform enqueued jobs' do
  around do |example|
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
    example.run
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = false
  end
end
