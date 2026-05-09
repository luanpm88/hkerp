# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

if defined?(Unicorn) && Rails.env.production?
  require 'unicorn/worker_killer'
  # Restart worker when RSS reaches a threshold in [400MB, 600MB].
  # Random within range so workers don't cycle simultaneously.
  use Unicorn::WorkerKiller::Oom, (1024**2 * 400), (1024**2 * 600)
end

run Rails.application
