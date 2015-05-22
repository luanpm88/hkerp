class City < ActiveRecord::Base
  include PgSearch
  
  validates :name, presence: true
  validate :unique_name_in_state
  
  belongs_to :state
  belongs_to :city_type
  
  def unique_name_in_state
    if City.where(state_id: self.state.id).where(name: self.name).where(city_type_id: self.city_type_id).count > 0      
      errors.add(:name, "already exsit in same state")
    end    
  end
  
  def self.scrape_source(link)
    m = Mechanize.new
    page = m.get(link)
    list = page.search(".wikitable").first.search("tr")
    
    vn = Country.where(name: "Việt Nam").first
    
    list.each do |node|
      if node.search("th").count == 0
        city_name = node.search("td")[1].content.strip
        state_name = node.search("td")[2].content.strip
        type_name = node.search("td")[3].content.strip
        
        if type_name == ""
          type_name = "huyện"
        end
        
        #save state
        state = State.where(name: state_name).first
        if state.nil?
          state = vn.states.create(name: state_name)
        end
        
        #save city types
        city_type = CityType.where(name: type_name).first
        if city_type.nil?
          city_type = CityType.create(name: type_name)
        end
        
        #save city
        city = state.cities.where(name: city_name, city_type_id: city_type.id).first
        if city.nil?
          city = state.cities.new(name: city_name)          
        end
        city.city_type = city_type
        city.save
        
        p vn.name+"-"+city_name+"-"+state_name+"-"+type_name
      end      
    end
  end
  
  pg_search_scope :search,
                against: [:name],
                associated_against: {
                  state: [:name],
                  city_type: [:name]
                },
                using: {
                  tsearch: {
                    dictionary: 'english',
                    any_word: true,
                    prefix: true
                  }
                }
  
  def self.full_text_search(q)
    self.search(q).limit(50).map {|model| {:id => model.id, :text => model.name_with_state} }
  end
  
  def name_with_state
    city_type.short_name+". "+name.gsub("Quận ","")+", "+state.name
  end
  
  def system_name
    city_type.short_name+". "+name.gsub("Quận ","")+"<br />"+state.name
  end
end
