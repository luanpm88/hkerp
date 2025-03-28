# set path to application
app_dir = File.expand_path("../..", __FILE__)
shared_dir = '/home/hoangkhang/hkerp/shared'
working_directory app_dir


# Set unicorn options
#worker_processes 2
worker_processes Etc.nprocessors
preload_app true
timeout 3600

# Set up socket location
listen "#{shared_dir}/sockets/unicorn.sock", :backlog => 64

# Logging
stderr_path "#{shared_dir}/log/unicorn.stderr.log"
stdout_path "#{shared_dir}/log/unicorn.stdout.log"

# Set master PID location
pid "#{shared_dir}/pids/unicorn.pid"
