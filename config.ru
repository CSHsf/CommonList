Bundler.require
require File.expand_path('main.rb',  File.dirname(__FILE__))
Dir[File.expand_path('models/*.rb', File.dirname(__FILE__))].each { |file| require file }
Dir[File.expand_path('config/initializers/*.rb', File.dirname(__FILE__))].each { |file| require file }

run ListService
