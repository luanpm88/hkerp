class Category < ActiveRecord::Base
  include PgSearch
  
  after_save :update_cache_search
  
  validates :name, presence: true, :uniqueness => true
  
  has_and_belongs_to_many :products
  
  has_many :parent_categories, :dependent => :destroy
  has_many :parent, :through => :parent_categories, :source => :parent
  has_many :child_categories, :class_name => "ParentCategory", :foreign_key => "parent_id", :dependent => :destroy
  has_many :children, :through => :child_categories, :source => :category
  
  def update_level(lvl)
    self.level = lvl
    self.save
  end
  
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
    rows = self.all
    if q.present?
      q.split(" ").each do |k|
        rows = rows.where("LOWER(categories.cache_search) LIKE ?", "%#{k.strip.downcase}%") if k.strip.present?
      end
    end
    
    rows = rows.limit(50).map {|model| {:id => model.id, :text => model.name} }
    
    new_rows = []
    new_rows << {id: "", text: "No category"}
    rows.each do |row|
      if self.find(row[:id]).children == []
        new_rows << row
      end
    end
    
    return new_rows
  end
  
  def update_cache_search
    str = []
    str << name.to_s.downcase.strip
    
    self.update_column(:cache_search, str.join(" ") + " " + str.join(" ").unaccent)
  end
  
end
