worker_processes 1

listen "/var/tmp/dev.commonlist.socket", :backlog => 8
user 'dev-commonlist-deployer'
pid "/var/tmp/dev.commonlist.pid"

root = "/var/www/dev.lists.delaha.us/current"
working_directory root

stderr_path "#{root}/log/unicorn.stderr.log"
stdout_path "#{root}/log/unicorn.stdout.log"

# nuke workers after 30 seconds instead of 60 seconds (the default)
timeout 30
