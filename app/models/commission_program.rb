class CommissionProgram < ActiveRecord::Base
  validates :name, presence: true, :uniqueness => true
  validates :interval_type, presence: true
  validates :min_amount, presence: true
  validates :published_at, presence: true
  validates :unpublished_at, presence: true
  validates :description, presence: true
  validates :commission_rate, presence: true
  
  belongs_to :user
  
  def self.all_commission_programs
    order("created_at DESC")
  end
  
  def min_amount=(new_price)
    self[:min_amount] = new_price.to_s.gsub(/\,/, '')
  end
  def max_amount=(new_price)
    self[:max_amount] = new_price.to_s.gsub(/\,/, '')
  end
  
  def start
    if status == 0
      self.update_attribute(:status, 1)
      return true
    else
      return false
    end
  end
  
  def stop
    if status == 1
      self.update_attribute(:status, 0)
      return true
    else
      return false
    end
  end
end
