class Checkinout < ActiveRecord::Base
  
  validates :user_id, presence: true
  validates :check_time, presence: true
  validates :check_date, presence: true
  
  Time.zone = "Asia/Bangkok"
  
  @@default_hours_per_month = 208
  cattr_reader :default_hours_per_month
  
  @@in_morning_time = {:hour => 7 , :min => 30 , :sec => 0 }
  @@out_morning_time = {:hour => 11 , :min => 30 , :sec => 0 }
  @@in_noon_time = {:hour => 13 , :min => 0 , :sec => 0 }
  @@out_noon_time = {:hour => 17 , :min => 0 , :sec => 0 }
  @@work_time_per_day = 8*60*60
  @@max_time = !Checkinout.where('note=?', 'imported').order("check_time DESC").empty? ? Checkinout.where('note=?', 'imported').order("check_time DESC").first.check_time : Time.zone.parse("2010-01-01")

  @@min_date = Time.zone.parse("2014-07-01")

  
  
  belongs_to :user, primary_key: 'ATT_No', foreign_key: 'user_id'
  belongs_to :checkinout_request
  
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
        
        if current_day != id+day && t >= @@min_date
          current_day = id+day          
          
          #save to checkinout table
          if self.where(user_id: id, check_date: t.to_date).empty?
            self.create(user_id: id, check_time: t, check_date: t.to_date, note: 'imported')
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
  
  def self.get_by_month(user, month, year)    
    time_string = year.to_s+"-"+month.to_s
    checks = []
    (1..31).each do |i|
      time = Time.zone.parse(time_string+"-"+i.to_s)
      if time.strftime("%m").to_i == month
        esxit = self.where(user_id: user.ATT_No, check_date: time.to_date)
        if esxit.count > 0
          checks << esxit.first
        else
          note = time > @@max_time ? "<span class='grey'>updating...</span>" : 'imported'
          checks << self.new(user_id: user.ATT_No, check_time: time,check_date: time.to_date, note: note)
        end
      end      
    end
    return checks
  end
  
  def get_result   
    if self.id.nil?
      if self.check_time > @@max_time
        return "<span class='grey'>updating...</span>"
      else
        if self.check_time.wday == 0
          return "holiday"
        else
          return "<span class='red'>absent</span>"
        end
      end
    else      
      late = self.get_late
      
      if late > 0        
        return "<span class='orange'>late ("+Checkinout.format_time(late)+")</span>"
      else
        return "<span class='green'>on time</span>"
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
    return more > @@work_time_per_day ? @@work_time_per_day : more;
  end
  
  def self.get_work_time_by_month(user, month, year)
    checks = self.get_by_month(user, month, year)
    
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
  
  def work_time_formated
    if self.check_time > @@max_time && self.note != 'custom' && self.note != 'requested'
      return "<span class='grey'>updating...</span>"
    end
    
    if self.check_time.wday == 0
      return "----"
    end
    
    if self.id.nil?
      return "0 hour(s)"
    end
    
    late = self.get_late > 0 ? self.get_late : 0;
    #return Checkinout.format_time(@@work_time_per_day - late)
    return ((@@work_time_per_day - late)/3600).round(2).to_s+" hour(s)"
    
  end
  
  def check_time_formated   
    
    if self.check_time > @@max_time && self.note != 'custom' && self.note != 'requested'
      return "<span class='grey'>updating...</span>"
    end
    
    if self.id.nil?
      return "--:--:--"
    end
    
    return self.check_time.strftime("%H:%M:%S")

  end
  
  
  
end
