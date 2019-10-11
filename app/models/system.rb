require "rmega"
require "google_drive"

class System < ActiveRecord::Base
  def self.columns
    @columns ||= [];
  end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default,
      sql_type.to_s, null)
  end

  # Override the save method to prevent exceptions.
  def save(validate = true)
    validate ? valid? : true
  end

  def self.backup(params)
    root_dir = params[:dir].present? ? params[:dir] : ""
    bk_dir = root_dir+"../backup"
    database = YAML.load_file(root_dir+'config/database.yml')[params[:rails_env]]["database"]
    revision_max = 1

    # remove over 100 backup old
    @files = Dir.glob("#{bk_dir}/*").sort{|a,b| b <=> a}
    @files.each_with_index do |f,index|
      if index > revision_max-1
        `rm -rf #{f}`
      end
    end

    `mkdir #{bk_dir}` if !File.directory?(bk_dir)

    dir = Time.now.strftime("%Y_%m_%d_%H%M%S")
    dir += "_#{database}"
    dir += "_db" if !params[:database].nil?
    dir += "_source" if !params[:file].nil?


    #`mkdir backup` if !File.directory?("backup")
    #`mkdir #{bk_dir}/#{dir}`

    backup_cmd = "mkdir #{bk_dir}/#{dir} && "
    backup_cmd += "pg_dump #{database} >> #{bk_dir}/#{dir}/data.dump && " if params[:database].present?
    backup_cmd += "cp -a #{root_dir} #{bk_dir}/#{dir}/ && " if !params[:file].nil? && File.directory?("#{root_dir}uploads")
    backup_cmd += "zip -r #{bk_dir}/#{dir}.zip #{bk_dir}/#{dir} && "
    backup_cmd += "rm -rf #{bk_dir}/#{dir}"

    puts backup_cmd

    `#{backup_cmd} &`

    if !File.directory?(dir)
      `rm -rf #{bk_dir}/#{dir}`
    end
  end

  def self.upload_backup_to_dropbox(params)
    root_dir = params[:dir].present? ? params[:dir] : ""
    bk_dir = root_dir+"backup"
    revision_max = 5

    dropbox_list = `#{root_dir}dropbox_uploader.sh list`
    latest_backup_file = "no file"
    (Dir.glob("#{bk_dir}/*").sort{|a,b| b <=> a}).each do |f|
      if f.include?(".zip")
        latest_backup_file = f
        break
      end
    end
    if !dropbox_list.include?(latest_backup_file.split("/").last)
      # upload backup
      puts "uploading..."
      uploading = `#{root_dir}dropbox_uploader.sh upload #{latest_backup_file} /`
      puts "#{latest_backup_file.split("/").last} uploaded!"

      # remove over 10 backup old
      puts "remove old backup..."

      dropbox_list = `#{root_dir}dropbox_uploader.sh list`
      dropbox_files = []
      dropbox_list.split("\n [F]").each do |s|
        dropbox_files << s.split(" ").last.gsub("\n","") if s.include?(".zip")
      end
      dropbox_files = dropbox_files.sort{|a,b| b <=> a}
      dropbox_files.each_with_index do |f,index|
        if index > revision_max-1
          `#{root_dir}dropbox_uploader.sh delete #{f}`
          puts "#{f} deleted!"
        end
      end

      puts "Done!"
    end
  end

  # upload mega.nz
  def self.upload_backup_to_mega_nz(params)
    bk_dir = params[:backup_dir]
    root_dir = params[:dir].present? ? params[:dir] : ""
    revision_max = 10
    backup_folder_name = 'erp.hoangkhang.com.vn'

    # find lastest backup file
    latest_backup_file = nil
    (Dir.glob("#{bk_dir}/*").sort{|a,b| b <=> a}).each do |f|
      if f.include?(".zip")
        latest_backup_file = f
        break
      end
    end
    return if latest_backup_file.nil?
    file_name = latest_backup_file.split("/").last
    puts "Uploading... " + latest_backup_file

    storage = Rmega.login('timhangcongnghe.vn@gmail.com', 'aA456321@#$')

    # Find backup folder
    backup_folder = nil
    storage.root.folders.each do |folder|
      # puts "Folder #{folder.name} contains #{folder.files.size} files."
      backup_folder = folder if folder.name == backup_folder_name
    end
    backup_folder = storage.root.create_folder(backup_folder_name) if backup_folder.nil?

    # Check if already upload
    if backup_folder.files.find { |file| file.name == file_name }
      puts "file exists!"
      return
    end

    # upload file
    backup_folder.upload(latest_backup_file)

    # Delete last file if revision_max
    count = backup_folder.files.count
    backup_folder.files.each_with_index do |file,index|
      if count - index > revision_max
        puts "Deleting old backup... #{file.name}"
        file.delete
      end
    end

    puts "done"
  end

  # upload google drive
  def self.upload_backup_to_google_drive(params)
    bk_dir = params[:backup_dir]
    root_dir = params[:dir].present? ? params[:dir] : ""
    revision_max = params[:revision_max]
    backup_folder_name = 'erp.hoangkhang.com.vn'

    # find lastest backup file
    latest_backup_file = nil
    (Dir.glob("#{bk_dir}/*").sort{|a,b| b <=> a}).each do |f|
      if f.include?(".zip")
        latest_backup_file = f
        break
      end
    end
    return if latest_backup_file.nil?
    file_name = latest_backup_file.split("/").last
    puts "Uploading... " + latest_backup_file

    # Connect
    session = GoogleDrive::Session.from_config(params[:token])

    folder = session.collection_by_title(backup_folder_name)
    if !folder.present?
      folder = session.root_collection.create_subcollection(backup_folder_name)
    end

    files = folder.files

    # Check if already upload
    if files.find { |file| file.title == file_name }
      puts "file exists!"
      return
    end

    # upload file
    folder.upload_from_file(latest_backup_file, file_name, convert: false)

    # Delete last file if revision_max
    files = folder.files
    count = files.count
    files.each_with_index do |file,index|
      if index >= revision_max
        puts "Deleting old backup... #{file.title}"
        file.delete(true)
      end
    end

    puts "done"
  end

end
