worker_processes 4
timeout 30

if ENV.has_key?('PORT')
	listen ENV['PORT']
end
