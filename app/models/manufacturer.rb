class Manufacturer < ActiveRecord::Base
  include PgSearch
  
  validates :name, presence: true, :uniqueness => true, :case_sensitive => false
  
  has_many :products
  
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
    rows = self.search(q).limit(50).map {|model| {:id => model.id, :text => model.name} }
    
    new_rows = []
    new_rows << {id: "", text: "No manufacturer"}
    rows.each do |row|      
      new_rows << row
    end
    
    return new_rows
  end
end
