class Contact < ActiveRecord::Base
  validates :name, presence: true
  
  has_many :parent_contacts, :dependent => :destroy
  has_many :parent, :through => :parent_contacts, :source => :parent
  has_many :child_contacts, :class_name => "ParentContact", :foreign_key => "parent_id", :dependent => :destroy
  has_many :children, :through => :child_contacts, :source => :contact
  
  has_many :agents_contacts, :dependent => :destroy
  has_many :agents, :through => :agents_contacts, :source => :agent
  has_many :companies_contacts, :class_name => "ParentContact", :foreign_key => "parent_id", :dependent => :destroy
  has_many :companies, :through => :companies_contacts, :source => :contact
  
  belongs_to :contact_type
  
  def is_main
    parent.first.nil?
  end
  
  def self.main_contacts(options = {})
    if !options[:type].nil?
      Contact.where(:contact_type_id => options[:type]).where.not(:id => ParentContact.select(:contact_id).map(&:contact_id))
    else
      Contact.where.not(:id => ParentContact.select(:contact_id).map(&:contact_id))
    end
  end
  
  def self.import(file)
    require 'roo'
    
    spreadsheet = Roo::Excelx.new(file.path, nil, :ignore)
    puts spreadsheet.sheets() 
    header = spreadsheet.row(6)
    
    result = Array.new
    
    (7..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i, "KHM")].transpose]
      
      str = String.new
      contact = Contact.new
      if !row["TÊN KHÁCH HÀNG"].nil?
        str = row["TÊN KHÁCH HÀNG"].strip
        str += " -- "+row["MST"].to_s.strip if !row["MST"].nil?
        str += " -- "+row["ĐỊA CHỈ"].to_s.strip if !row["ĐỊA CHỈ"].nil?
        str += " -- "+row["ĐIỆN THOẠI"].to_s.strip if !row["ĐIỆN THOẠI"].nil?
        str += " -- "+row["FAX"].to_s.strip if !row["FAX"].nil?
        str += " -- "+row["STK"].to_s.strip if !row["STK"].nil?
        str += " / "+row["TẠI NH"].to_s.strip if !row["TẠI NH"].nil?
        
        contact.name = row["TÊN KHÁCH HÀNG"].strip
        contact.tax_code = row["MST"].to_s.strip if !row["MST"].nil?
        contact.address = row["ĐỊA CHỈ"].to_s.strip if !row["ĐỊA CHỈ"].nil?
        contact.phone = row["ĐIỆN THOẠI"].to_s.strip if !row["ĐIỆN THOẠI"].nil?
        contact.fax = row["FAX"].to_s.strip if !row["FAX"].nil?
        
        note = String.new
        note = row["STK"].to_s.strip if !row["STK"].nil?
        note += " / "+row["TẠI NH"].to_s.strip if !row["TẠI NH"].nil?
        contact.note = note
        
        contact.save
      end
      
      result << str
    end
    
    return result
  end

end
