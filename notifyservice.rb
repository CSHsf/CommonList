require 'bundler'
Bundler.require

Dir[File.expand_path('models/*.rb', File.dirname(__FILE__))].each { |file| require file }
Dir[File.expand_path('config/initializers/*.rb', File.dirname(__FILE__))].each { |file| require file }

set :notify, YAML.load(ERB.new(File.read('config/notify.yml')).result)[Sinatra::Base.environment.to_s]
set :database, YAML.load(ERB.new(File.read('config/database.yml')).result)[Sinatra::Base.environment.to_s]

class NotifyService
	attr_reader :process_name, :pid_dir, :log_dir

	if settings.notify['delayed']
		class ::User
			handle_asynchronously :notify
		end
	end

	def initialize
		@process_name = 'Test'
		@pid_dir = File.join(settings.root, 'tmp', 'pids')
		@log_dir = File.join(settings.root, 'log')

		mkdir pid_dir unless File.exists? pid_dir
		mkdir log_dir unless File.exists? log_dir

		Delayed::Worker.logger ||= Logger.new(File.join(log_dir, 'delayed_job.log'))
	end

	def run
		#Daemons.run_proc(process_name, :dir => pid_dir, :dir_mode => :normal, :ARGV => ARGV) do |*args|
			begin
				worker = Delayed::Worker.new
				worker.name_prefix = "#{process_name} "
				worker.start
			rescue => e
				worker.logger.fatal e
				STDERR.puts e.message
				exit 1
			end
		#end
	end
end

NotifyService.new.run
exit 0
