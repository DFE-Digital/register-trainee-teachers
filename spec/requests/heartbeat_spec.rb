# frozen_string_literal: true

require "rails_helper"

describe "heartbeat requests" do
  describe "GET /ping" do
    it "returns PONG" do
      get "/ping"

      expect(response.body).to eq "PONG"
    end
  end

  describe "GET /healthcheck" do
    let(:stats)      { instance_double(Sidekiq::Stats) }
    let(:process)    { instance_double(Sidekiq::Process) }
    let(:queue_name) { "quest" }
    let(:queues)     { { queue_name => 0 } }

    before do
      allow(Sidekiq::Stats).to receive(:new).and_return(stats)
      allow(stats).to receive(:queues).and_return(queues)

      allow(Sidekiq::ProcessSet).to receive(:new).and_return([process])
      allow(process).to receive(:[]).with("queues").and_return([queue_name])

      allow(ActiveRecord::Base.connection).to receive(:active?).and_return(true)
      allow(Sidekiq).to receive(:redis_info).and_return({})
    end

    context "when everything is ok" do
      it "returns HTTP success" do
        get "/healthcheck"

        expect(response).to have_http_status :ok
      end

      it "returns JSON" do
        get "/healthcheck"
        expect(response.media_type).to eq("application/json")
      end

      it "returns the expected response report" do
        get "/healthcheck"

        expect(response.body).to eq({ checks: {
          database: true,
          redis: true,
          sidekiq_processes: true,
          solid_queue_processes: true,
        } }.to_json)
      end
    end

    context "when a Solid Queue queue has jobs" do
      before do
        SolidQueue::Job.create!(class_name: "DeleteEmptyTraineesJob", queue_name: "default")
      end

      context "with a live worker for the queue" do
        before do
          create_solid_queue_worker(queues: "default", last_heartbeat_at: Time.current)
        end

        it "sets the solid queue check to true" do
          get "/healthcheck"

          expect(response.parsed_body["checks"]).to include("solid_queue_processes" => true)
        end
      end

      context "without a worker for the queue" do
        before do
          create_solid_queue_worker(queues: "trs", last_heartbeat_at: Time.current)
        end

        it "returns 503" do
          get "/healthcheck"

          expect(response).to have_http_status :service_unavailable
        end

        it "sets the solid queue check to false" do
          get "/healthcheck"

          expect(response.parsed_body["checks"]).to include("solid_queue_processes" => false)
        end
      end

      context "with a worker whose heartbeat has stopped" do
        before do
          create_solid_queue_worker(queues: "default", last_heartbeat_at: 10.minutes.ago)
        end

        it "sets the solid queue check to false" do
          get "/healthcheck"

          expect(response.parsed_body["checks"]).to include("solid_queue_processes" => false)
        end
      end
    end

    context "there's no process for a queue" do
      before do
        allow(process).to receive(:[]).with("queues").and_return([])
      end

      it("returns 503") do
        get "/healthcheck"

        expect(response).to have_http_status :service_unavailable
      end

      it "sets the sidekiq queue to false" do
        get "/healthcheck"

        json_response = response.parsed_body

        expect(json_response["checks"]["sidekiq_processes"]).to be false
      end
    end

    context "there's no Redis connection" do
      before do
        allow(Sidekiq).to receive(:redis_info).and_raise(Errno::ECONNREFUSED)
      end

      it("returns 503") do
        get "/healthcheck"

        expect(response).to have_http_status :service_unavailable
      end

      it "sets the sidekiq queue to false" do
        get "/healthcheck"

        json_response = response.parsed_body

        expect(json_response["checks"]).to include("redis" => false)
      end
    end

    context "there's no db connection" do
      before do
        allow(ActiveRecord::Base)
          .to receive(:connected?).and_return(false)
      end

      it("returns 503") do
        get "/healthcheck"

        expect(response).to have_http_status :service_unavailable
      end

      it "sets the sidekiq queue to false" do
        get "/healthcheck"

        json_response = response.parsed_body

        expect(json_response["checks"]).to include("database" => false)
      end
    end
  end

  def create_solid_queue_worker(queues:, last_heartbeat_at:)
    SolidQueue::Process.create!(
      kind: "Worker",
      name: "worker-#{SecureRandom.hex(4)}",
      pid: 1,
      hostname: "test",
      last_heartbeat_at: last_heartbeat_at,
      metadata: { queues: },
    )
  end

  describe "GET /sha" do
    it "returns the sha from the env var COMMIT_SHA" do
      allow(ENV).to receive(:fetch).with("COMMIT_SHA", nil).and_return("deadbeef")

      get "/sha"

      expect(response.body).to eq '{"sha":"deadbeef"}'
    end
  end
end
