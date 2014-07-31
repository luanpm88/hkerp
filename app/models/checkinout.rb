class Checkinout < ActiveRecord::Base
  def self.import(file)
    require 'access_db'
    
    file = File.open(file.path)
    
    str = ""
    current_day = ""
    file.each_line do |line|
      begin
        t = DateTime.parse(line.split(",")[1])
        id = line.split(",")[0]
        day = t.strftime("%Y:%m:%d")
        
        if current_day != id+day
          current_day = id+day          
          
          #save to checkinout table
          if self.where(user_id: id, check_time: t).empty?
            self.create(user_id: id, check_time: t)
            str += id + ": " + t.to_formatted_s(:db) + " / " + t.strftime("%Y:%m:%d") + " :: new\n"
          else
            str += id + ": " + t.to_formatted_s(:db) + " / " + t.strftime("%Y:%m:%d") + " :: exsit\n"
          end
        else
          str += id + ": " + t.to_formatted_s(:db) + " / " + t.strftime("%Y:%m:%d") + "####\n"
        end      
        
      rescue
      end
    end
    
    File.open("public/log.txt", "w") { |file| file.write str }
  end
end
