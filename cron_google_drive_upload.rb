require 'active_record'
require 'yaml'
DIR = File.expand_path(File.dirname(__FILE__))

#Item class
require DIR+'/app/models/system.rb'

System.upload_backup_to_google_drive({
  backup_dir: DIR+'/backup',
  dir: DIR+'/',
  token: DIR+'/cron_google_drive_token.conf',
  revision_max: 1
})
