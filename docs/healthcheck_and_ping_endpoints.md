# Healthcheck and Ping Endpoints

Healthchecks are handled by [`HeartbeatController`](../app/controllers/heartbeat_controller.rb).

## Ping

Use the `/ping` endpoint as a lightweight check to see if the app is up. This
can be used by load-balancers, for example, which may frequently test whether to
send traffic to a given host running this app. The response will simply be
`PONG`, with a 200 status code, and not specific resources are checked when this
endpoint is activated.

## Healthcheck

Use the `/healthcheck` to check whether that the app’s dependencies are working.
This returns a JSON structure that lists the checks it performs and their
results. For example:

```json
{
  "checks": {
    "database": true,
    "redis": true,
    "solid_queue_processes": true
  }
}
```

The available checks:

### `database`

Check that ‘ActiveRecord’ connection to the database is active.

### `redis`

Checks that the app can connect to the Redis server that form drafts fall back
to while they move to Solid Cache.

### `solid_queue_processes`

Check which queues have jobs in Solid Queue. Then check that there is a live
Solid Queue worker for each one. A worker is live if it sent a heartbeat within
`SolidQueue.process_alive_threshold` (5 minutes by default).

Solid Queue keeps finished jobs for a day, so a queue counts as being used if it
had a job in that time.

#### Failures caused by stale jobs

You can check which queues have a live worker by starting the Rails console and
running:

```ruby
live_queues = SolidQueue::Process
  .where(kind: "Worker", last_heartbeat_at: SolidQueue.process_alive_threshold.ago..)
  .flat_map { |process| process.metadata["queues"].to_s.split(",") }
SolidQueue::Queue.all.each do |queue|
  puts "#{queue.name} running? #{queue.name.in?(live_queues)}"
end
```

If a queue should not be used any more, discard its jobs in Mission Control
(`/system-admin/jobs`). Finished jobs are cleared after a day by the
`clear_solid_queue_finished_jobs` recurring task.
