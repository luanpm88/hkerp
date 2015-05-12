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
    self.search(q).limit(50).map {|model| {:id => model.id, :text => model.name} }
  end
end
