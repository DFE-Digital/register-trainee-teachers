# frozen_string_literal: true

require "sidekiq/api"

class HeartbeatController < ActionController::API
  def ping
    render(body: "PONG")
  end

  def healthcheck
    checks = {
      database: database_alive?,
      redis: redis_alive?,
      sidekiq_processes: sidekiq_processes_checks,
      solid_queue_processes: solid_queue_processes_check,
    }

    status = checks.values.all? ? :ok : :service_unavailable

    render(status: status,
           json: {
             checks:,
           })
  end

  def sha
    render(json: { sha: ENV.fetch("COMMIT_SHA", nil) })
  end

private

  def database_alive?
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      conn.execute("SELECT 1")
    end

    ActiveRecord::Base.connected?
  rescue ActiveRecord::ConnectionNotEstablished, PG::ConnectionBad
    false
  end

  def redis_alive?
    Sidekiq.redis_info
    true
  rescue StandardError
    false
  end

  def sidekiq_processes_checks
    stats = Sidekiq::Stats.new
    processes = Sidekiq::ProcessSet.new

    # Iterate over each Sidekiq queue and ensure that there is a process
    # running for it.
    stats.queues.keys.all? do |queue|
      processes.any? { |process| queue.in?(process["queues"]) }
    end
  rescue StandardError
    false
  end

  def solid_queue_processes_check
    # Iterate over each Solid Queue queue and ensure that there is a worker
    # running for it.
    live_queues = SolidQueue::Process
      .where(kind: "Worker", last_heartbeat_at: SolidQueue.process_alive_threshold.ago..)
      .flat_map { |process| process.metadata["queues"].to_s.split(",") }

    SolidQueue::Queue.all.all? { |queue| queue.name.in?(live_queues) }
  rescue StandardError
    false
  end
end
