class Checkinout < ActiveRecord::Base
  @@in_morning_time = {:hour => 7 , :min => 30 , :sec => 0 }
  @@out_morning_time = {:hour => 11 , :min => 30 , :sec => 0 }
  @@in_noon_time = {:hour => 13 , :min => 0 , :sec => 0 }
  @@out_noon_time = {:hour => 17 , :min => 0 , :sec => 0 }
  @@work_time_per_day = 8*60*60
  
  
  belongs_to :user, primary_key: 'ATT_No', foreign_key: 'user_id'
  
  def self.import(file)
    require 'access_db'
    
    file = File.open(file.path)
    
    str = ""
    current_day = ""
    file.each_line do |line|
      begin
        Time.zone = "Asia/Bangkok"
        t = Time.zone.parse(line.split(",")[1])
        id = line.split(",")[0]
        day = t.strftime("%Y:%m:%d")
        
        if current_day != id+day
          current_day = id+day          
          
          #save to checkinout table
          if self.where(user_id: id, check_date: t.to_date).empty?
            self.create(user_id: id, check_time: t, check_date: t.to_date)
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
  
  def self.get_by_month(user, month)    
    Time.zone = "Asia/Bangkok"
    now = Time.zone.now
    time_string = now.strftime("%Y")+"-"+month.to_s
    checks = []
    (1..31).each do |i|
      time = Time.zone.parse(time_string+"-"+i.to_s)
      if time.strftime("%m").to_i == month
        esxit = self.where(user_id: user.ATT_No, check_date: time.to_date)
        if esxit.count > 0
          checks << esxit.first
        else
          checks << self.new(user_id: user.ATT_No, check_time: time,check_date: time.to_date)
        end
      end      
    end
    return checks
  end
  
  def get_result   
    if self.id.nil?
      if self.check_time.wday == 0
        return "holiday"
      else
        return "absent"
      end      
    else      
      late = self.get_late
      
      if late > 0        
        return Checkinout.format_time(late)+" late"
      else
        return "on time"
      end
    end
    
  end
  
  def get_late
    Time.zone = "Asia/Bangkok"
    if self.check_time > Time.zone.parse(self.check_date.to_s).change(@@out_morning_time)
      more = self.check_time - Time.zone.parse(self.check_date.to_s).change(@@in_noon_time)
      if more > 0
        more = more + 4*60*60
      else
        more = 4*60*60
      end
    else
      more = self.check_time - Time.zone.parse(self.check_date.to_s).change(@@in_morning_time)
    end
    return more
  end
  
  def self.get_work_time_by_month(user, month)
    checks = self.get_by_month(user, month)
    
    sum = 0
    checks.each do |check|
      if !check.id.nil?
        sum += check.work_time
      end
    end
    return sum
  end
  
  def self.format_time(time)
    hours = ("%02d" % (time/3600).to_i).to_s
    minutes = ("%02d" % ((time%3600)/60).to_i).to_s
    second = ("%02d" % ((time%3600)%60).to_i).to_s
    return hours+":"+minutes+":"+second
  end
  
  def work_time
    return @@work_time_per_day - self.get_late
  end
  
end