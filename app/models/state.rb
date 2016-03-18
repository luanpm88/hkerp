class State < ActiveRecord::Base
  include PgSearch
  
  validates :name, presence: true, :uniqueness => true
  
  belongs_to :country
  has_many :cities
  
  pg_search_scope :search,
                against: [:name],
                using: {
                  tsearch: {
                    dictionary: 'english',
                    any_word: true,
                    prefix: true
                  }
                }
  
  def self.full_text_search(q)
    result = self.search(q).limit(25).map {|model| {:id => "s_"+model.id.to_s, :text => model.name} }
    result += City.search(q).limit(25).map {|model| {:id => "c_"+model.id.to_s, :text => model.name_with_state} }
    
    return result
  end
end
