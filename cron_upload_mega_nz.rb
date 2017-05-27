require 'active_record'
require 'yaml'
DIR = File.expand_path(File.dirname(__FILE__))

#Item class
require DIR+'/app/models/system.rb'

System.upload_backup_to_mega_nz({
  backup_dir: DIR+'/backup',
  dir: DIR+'/'
})
