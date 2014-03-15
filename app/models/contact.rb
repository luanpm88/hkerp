class Contact < ActiveRecord::Base
  validates :name, presence: true, :uniqueness => true
  validates :contact_type_id, presence: true
  
  has_many :parent_contacts, :dependent => :destroy
  has_many :parent, :through => :parent_contacts, :source => :parent
  has_many :child_contacts, :class_name => "ParentContact", :foreign_key => "parent_id", :dependent => :destroy
  has_many :children, :through => :child_contacts, :source => :contact
  
  has_many :agents_contacts, :dependent => :destroy
  has_many :agents, :through => :agents_contacts, :source => :agent
  has_many :companies_contacts, :class_name => "AgentsContact", :foreign_key => "agent_id", :dependent => :destroy
  has_many :companies, :through => :companies_contacts, :source => :contact
  
  
  belongs_to :contact_type
  belongs_to :user
  
  def is_main
    parent.first.nil? && !is_agent
  end
  
  def is_agent
    contact_type.id.to_s == ContactType.agent
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
    header = spreadsheet.row(1)
    
    result = Array.new
    
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i, "KH2014")].transpose]
      
      str = String.new
      contact = Contact.new
      if !row["TÊN ĐƠN VỊ"].nil?
        str = row["TÊN ĐƠN VỊ"].strip

        
        contact.name = row["TÊN ĐƠN VỊ"].strip
        contact.contact_type_id = ContactType.customer
        contact.tax_code = row["MST"].to_s.strip if !row["MST"].nil?
        contact.address = row["ĐỊA CHỈ"].to_s.strip if !row["ĐỊA CHỈ"].nil?
        contact.phone = row["SỐ ĐIỆN THOẠI"].to_s.strip if !row["ĐIỆN THOẠI"].nil?
        contact.fax = row["SỐ FAX"].to_s.strip if !row["SỐ FAX"].nil?
        contact.email = row["EMAIL CÔNG TY"].to_s.strip if !row["EMAIL CÔNG TY"].nil?
        
        contact.website = row["WEBSITE"].to_s.strip if !row["WEBSITE"].nil?
        contact.account_number = row["SỐ TÀI KHOẢN"].to_s.strip if !row["SỐ TÀI KHOẢN"].nil?
        contact.bank = row["NGÂN HÀNG"].to_s.strip if !row["NGÂN HÀNG"].nil?
        contact.representative = row["NGƯỜI ĐẠI DIỆN"].to_s.strip if !row["NGƯỜI ĐẠI DIỆN"].nil?
        contact.representative_role = row["CHỨC VỤ"].to_s.strip if !row["CHỨC VỤ"].nil?
        contact.representative_phone = row["SỐ ĐT ĐẠI DIỆN"].to_s.strip if !row["SỐ ĐT ĐẠI DIỆN"].nil?
        
        contact.save
        
        if !row["TÊN NGƯỜI LIÊN HỆ"].nil?
          agent = Contact.new
          
          if row["TÊN NGƯỜI LIÊN HỆ"].strip.split(/,/).length > 1
            names = row["TÊN NGƯỜI LIÊN HỆ"].strip.split(/,/)
            
            names.each_with_index {|name, index|            
              agent = Contact.new
              
              agent.contact_type_id = ContactType.agent
              agent.name = name.strip
              
              
              agent.phone = row["SỐ ĐT NGƯỜI LIÊN HỆ"].to_s.split(/,/)[index].to_s.strip if !row["SỐ ĐT NGƯỜI LIÊN HỆ"].nil?
              agent.email = row["EMAIL NGƯỜI LIÊN HỆ"].to_s.split(/,/)[index].to_s.strip if !row["EMAIL NGƯỜI LIÊN HỆ"].nil?
              agent.account_number = row["SỐ TÀI KHOẢN NGƯỜI LIÊN HỆ"].to_s.split(/,/)[index].to_s.strip if !row["SỐ TÀI KHOẢN NGƯỜI LIÊN HỆ"].nil?
              agent.bank = row["NGÂN HÀNG NGƯỜI LH"].to_s.split(/,/)[index].to_s.strip if !row["NGÂN HÀNG NGƯỜI LH"].nil?
              
              agent.companies << contact
            
              agent.save
            }
            
          else
            agent = Contact.new
            
            agent.contact_type_id = ContactType.agent
            agent.name = row["TÊN NGƯỜI LIÊN HỆ"].strip
            agent.phone = row["SỐ ĐT NGƯỜI LIÊN HỆ"].to_s.strip if !row["SỐ ĐT NGƯỜI LIÊN HỆ"].nil?
            agent.email = row["EMAIL NGƯỜI LIÊN HỆ"].to_s.strip if !row["EMAIL NGƯỜI LIÊN HỆ"].nil?
            agent.account_number = row["SỐ TÀI KHOẢN NGƯỜI LIÊN HỆ"].to_s.strip if !row["SỐ TÀI KHOẢN NGƯỜI LIÊN HỆ"].nil?
            agent.bank = row["NGÂN HÀNG NGƯỜI LH"].to_s.strip if !row["NGÂN HÀNG NGƯỜI LH"].nil?
            
            agent.companies << contact
          
            agent.save
          end
          
        end
        
        
        #note = String.new
        #note = row["STK"].to_s.strip if !row["STK"].nil?
        #note += " / "+row["TẠI NH"].to_s.strip if !row["TẠI NH"].nil?
        #contact.note = note
        
        #contact.save
      end
      
      result << str
    end
    
    return result
  end
  
  def html_info_line
    line = "";
    if !address.nil? && !address.empty?
      line += "<p>" + address + "</p>"
    end
    if !phone.nil? && !phone.empty?
      line += "<strong>Phone:</strong> " + phone + " "
    end
    if !fax.nil? && !fax.empty?
      line += "<strong>Fax:</strong> " + fax + " "
    end
    if !tax_code.nil? && !tax_code.empty?
      line += "<strong>MST:</strong> " + tax_code + " "
    end
    
    return line
  end
  
  def html_agent_line
    line = "";
    line += "<strong>" + name + "</strong><br /> "

    if !phone.nil? && !phone.empty?
      line += "phone: " + phone + " "
    end
    if !mobile.nil? && !mobile.empty?
      line += "mobile: " + mobile + " "
    end
    if !email.nil? && !email.empty?
      line += "email: " + email + " "
    end
    
    return line
  end
  
  def html_agent_input
    line = "";
    line += name

    if !phone.nil? && !phone.empty?
      line += "; phone: " + phone + " "
    end
    if !mobile.nil? && !mobile.empty?
      line += "; mobile: " + mobile + " "
    end
    if !email.nil? && !email.empty?
      line += "; email: " + email + " "
    end
    
    return line
  end
  
  def self.HK
    Contact.find(:first, :conditions => {:is_mine => true})
  end
  
end
