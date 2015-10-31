#dropbox_list = `/home/luan/Dropbox-Uploader/dropbox_uploader.sh list`
#latest_backup_file = (Dir.glob("/media/sdb1/ftms-backup/*").sort{|a,b| b <=> a})[0]
#if !dropbox_list.include?(latest_backup_file.split("/").last)
#  # upload backup
#  uploading = `~/Dropbox-Uploader/dropbox_uploader.sh upload #{latest_backup_file} /`
#  
#  # remove over 10 backup old
#  dropbox_files = []
#  dropbox_list.split("\n [F] 0 ").each do |s|
#    dropbox_files << s.gsub("\n","") if s.include?(".zip")
#  end
#  dropbox_files = dropbox_files.sort{|a,b| b <=> a}
#  dropbox_files.each_with_index do |f,index|
#    if index > 0
#      `/home/luan/Dropbox-Uploader/dropbox_uploader.sh delete #{f}`
#    end
#  end
#end
#uploading = `~/Dropbox-Uploader/dropbox_uploader.sh upload #{latest_backup_file} /`

require 'active_record'
require 'yaml'
DIR = File.expand_path(File.dirname(__FILE__))

# Change the following to reflect your database settings
# config = YAML.load_file(DIR+'/config/database.yml')["production"]
config = YAML.load_file(DIR+'/config/database.yml')["production"]

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
require DIR+'/app/models/system.rb'

System.upload_backup_to_dropbox({dir: DIR+"/"})









