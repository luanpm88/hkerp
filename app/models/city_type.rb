class CityType < ActiveRecord::Base
  validates :name, presence: true, :uniqueness => true
  
  has_many :cities
  
  def short_name
    result = ""
    name.split(" ").each do |word|
      first_l = word[0].upcase
      first_l = "Đ" if first_l == "đ"
      result += first_l
    end
    
    return result
  end
end
