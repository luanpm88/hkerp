class CheckinoutRequest < ActiveRecord::Base
  validates :user_id, presence: true
  validates :check_time, presence: true
  validates :content, presence: true
  
  belongs_to :user
  belongs_to :manager, :class_name => "User", :foreign_key => "manager_id"
  
  has_many :checkinouts
  
  def status_string
    if self.status == 0
      return "waiting"
    end
    if self.status == 1
      return "approved"
    end
    if self.status == -1
      return "rejected"
    end
  end
  
  def approve_request
    #update checkinout
    checkinout = Checkinout.where(user_id: self.user.ATT_No, check_date: self.check_time.to_date).first
    if checkinout.nil?
      checkinout = Checkinout.create(checkinout_request_id: self.id,user_id: self.user.ATT_No, check_date: self.check_time.to_date, check_time: self.check_time, note: 'requested')
    else
      checkinout.checkinout_request = self
      checkinout.check_time = self.check_time
      checkinout.check_date = self.check_time.to_date
      checkinout.note = 'requested'
      checkinout.save
    end
  end
  
end
