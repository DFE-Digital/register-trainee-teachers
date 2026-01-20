# frozen_string_literal: true

# This configuration file will be evaluated by Puma. The top-level methods that
#                                                                                                                                           0o
# are invoked here are part of Puma's configuration DSL. For more information
# about methods provided by the DSL, see https://puma.io/puma/Puma/DSL.html.

max_threads_count = ENV.fetch("RAILS_MAX_THREADS", 5)
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

env = ENV.fetch("RAILS_ENV", "development")
environment env

# Puma starts a configurable number of processes (workers) and each process
# serves each request in a thread from an internal thread pool.

listen_port = ENV.fetch("PORT", 5000)

# You can control the number of workers using ENV["WEB_CONCURRENCY"]. You
# should only set this value when you want to run 2 or more workers. The
# default is already 1.
#
# The ideal number of threads per worker depends both on how much time the
# application spends waiting for IO operations and on how much you wish to
# prioritize throughput over latency.
#
# As a rule of thumb, increasing the number of threads will increase how much
# traffic a given process can handle (throughput), but due to CRuby's
# Global VM Lock (GVL) it has diminishing returns and will degrade the
# response time (latency) of the application.
#
# The default is set to 3 threads as it's deemed a decent compromise between
# throughput and latency for the average Rails application.
#
# Any libraries that use a connection pool or another resource pool should
# be configured to provide at least as many connections as the number of
# threads. This includes Active Record's `pool` parameter in `database.yml`.
if env == "development" && FeatureService.enabled?("use_ssl")
  cert = "#{Dir.pwd}/#{File.join('config', 'localhost', 'https', 'localhost.crt')}"
  key = "#{Dir.pwd}/#{File.join('config', 'localhost', 'https', 'localhost.key')}"

  unless File.exist?(cert) && File.exist?(key)
    def generate_root_cert(root_key)
      root_ca = OpenSSL::X509::Certificate.new
      root_ca.version = 2 # cf. RFC 5280 - to make it a "v3" certificate
      root_ca.serial = rand(100_000) # randomized for local development to prevent SEC_ERROR_REUSED_ISSUER_AND_SERIAL errors in firefox after a git-clean
      root_ca.subject = OpenSSL::X509::Name.parse("/C=GB/L=London/O=DfE/CN=localhost")
      root_ca.issuer = root_ca.subject # root CA's are "self-signed"
      root_ca.public_key = root_key.public_key
      root_ca.not_before = Time.zone.now
      root_ca.not_after = root_ca.not_before + (2 * 365 * 24 * 60 * 60) # 2 years validity
      root_ca.sign(root_key, OpenSSL::Digest.new("SHA256"))
      root_ca
    end

    root_key = OpenSSL::PKey::RSA.new(2048)
    File.write(key, root_key, mode: "wb")

    root_cert = generate_root_cert(root_key)
    File.write(cert, root_cert, mode: "wb")
  end

  ssl_bind "0.0.0.0", listen_port, cert: cert, key: key, verify_mode: "none"
else
  port listen_port
end

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
port ENV.fetch("PORT", 5000)

# Specify the PID file. Defaults to tmp/pids/server.pid in development.
# In other environments, only set the PID file if requested.
pidfile ENV["PIDFILE"] if ENV["PIDFILE"]
