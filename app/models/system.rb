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
    bk_dir = root_dir+"backup"
    database = YAML.load_file(root_dir+'config/database.yml')[params[:rails_env]]["database"]
    revision_max = 100
    
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
    backup_cmd += "pg_dump -a #{database} >> #{bk_dir}/#{dir}/data.dump && " if params[:database].present?
    backup_cmd += "cp -a #{root_dir}uploads #{bk_dir}/#{dir}/ && " if !params[:file].nil? && File.directory?("#{root_dir}uploads")
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
end