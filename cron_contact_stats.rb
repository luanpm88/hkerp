require 'active_record'
require 'yaml'
DIR = File.expand_path(File.dirname(__FILE__))
rails_env = "production"
# Change the following to reflect your database settings
# config = YAML.load_file(DIR+'/config/database.yml')["production"]
config = YAML.load_file(DIR+'/config/database.yml')[rails_env]

puts DIR+'/config/database.yml'

ActiveRecord::Base.establish_connection(
  adapter: config["adapter"],
  encoding: config["encoding"],
  database: config["database"],
  pool: 5,
  username: config["username"],
  password: config["password"]
)

#Item class
require DIR+'/app/models/contact_stat.rb'
require DIR+'/app/models/contact.rb'
require DIR+'/app/models/order.rb'
require DIR+'/app/uploaders/logo_uploader.rb'

Contact.first.update_stats
