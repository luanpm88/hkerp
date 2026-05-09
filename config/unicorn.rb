# set path to application
app_dir = File.expand_path("../..", __FILE__)
shared_dir = '/home/hoangkhang/hkerp/shared'
working_directory app_dir


# Set unicorn options
#worker_processes 2
worker_processes Etc.nprocessors
preload_app true
timeout 3600

# Skip request body if client already disconnected
check_client_connection true

# Set up socket location
listen "#{shared_dir}/sockets/unicorn.sock", :backlog => 1024

# Logging
stderr_path "#{shared_dir}/log/unicorn.stderr.log"
stdout_path "#{shared_dir}/log/unicorn.stdout.log"

# Set master PID location
pid "#{shared_dir}/pids/unicorn.pid"

# Zero-downtime restart hooks for `kill -USR2 <master>`.
# Without these, USR2 leaves the old master + workers running indefinitely
# (the cause of the May-3 zombie masters).
before_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exist?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end
