class Contact < ActiveRecord::Base
  mount_uploader :image, LogoUploader

  after_save :update_cache_search

  include PgSearch

  validates :name, presence: true
  validates :contact_types, presence: true

  has_many :parent_contacts, :dependent => :destroy
  has_many :parent, :through => :parent_contacts, :source => :parent
  has_many :child_contacts, :class_name => "ParentContact", :foreign_key => "parent_id", :dependent => :destroy
  has_many :children, :through => :child_contacts, :source => :contact

  has_many :agents_contacts, :dependent => :destroy
  has_many :agents, :through => :agents_contacts, :source => :agent, :dependent => :destroy
  has_many :companies_contacts, :class_name => "AgentsContact", :foreign_key => "agent_id", :dependent => :destroy
  has_many :companies, :through => :companies_contacts, :source => :contact

  has_many :contact_types_contacts

  belongs_to :contact_type
  belongs_to :user

  belongs_to :city
  has_one :state, :through => :city

  has_and_belongs_to_many :contact_types

  after_validation :update_cache

  def self.datatable(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers

    @records = self.main_contacts
    @records = @records.where_by_types(params[:types].split(",")) if params[:types].present?
    if !user.can?(:view_suppliers, Contact)
      @records = @records.where("contacts.contact_types_cache NOT LIKE '%[#{ContactType.supplier}]%'")
    end
    if params[:area_id].present?
      area_type = params[:area_id].split("_")[0]
      area_id = params[:area_id].split("_")[1]
      if area_type == "c"
        @records = @records.where(city_id: area_id)
      elsif area_type == "s"
        city_ids = State.find(area_id.to_i).cities.map{|c| c.id}
        @records = @records.where(city_id: city_ids)
      end
    end

    # @records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?

    if params["search"]["value"].present?
      params["search"]["value"].split(" ").each do |k|
        @records = @records.where("LOWER(contacts.cache_search) LIKE ? OR LOWER(contacts.cache_search) LIKE ?", "%#{k.strip.downcase}%", "%#{k.strip.unaccent.downcase}%") if k.strip.present?
      end
    end


    if !user.can?(:view_all_customers, Contact)
      @records = @records.where(user_id: user.id)
    end


    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    data = []

    actions_col = 5
    @records.each do |item|
      item = [
              link_helper.link_to("<img width='60' src='#{item.logo(:thumb)}' />".html_safe, {controller: "contacts", action: "edit", id: item.id, tab_page: 1}, class: "main-title tab_page", title: item.short_name),
              link_helper.link_to(item.name, {controller: "contacts", action: "edit", id: item.id, tab_page: 1}, class: "main-title tab_page", title: item.short_name)+item.html_info_line.html_safe,
              '<div class="text-center nowrap">'+item.city_name+"</div>",
              item.agent_list_html,
              '<div class="text-center">'+(item.user.nil? ? "" : item.user.staff_col)+"</div>",
              '',
            ]
      data << item

    end

    result = {
              "drawn" => params[:drawn],
              "recordsTotal" => total,
              "recordsFiltered" => total
    }
    result["data"] = data

    return {result: result, items: @records, actions_col: actions_col}
  end

  def city_name
    city.present? ? city.system_name : ""
  end

  def self.where_by_types(types)
    wheres = []
    types.each do |t|
      wheres << "contacts.contact_types_cache LIKE '%[#{t}]%'"
    end
    where("(#{wheres.join(" OR ")})")
  end

  def is_main
    parent.first.nil? && !is_agent
  end

  def is_agent
    contact_types.include?(ContactType.agent)
  end

  def self.main_contacts
    self.where.not(:id => ParentContact.select(:contact_id).map(&:contact_id))
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
        contact.contact_type_id = ContactType.supplier
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
        contact.note = row["NOTE"].to_s.strip if !row["NOTE"].nil?

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
      line += "<p>" + full_address + "</p>"
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
    Contact.where(is_mine: true).first
  end

  pg_search_scope :search,
                against: [:name, :address, :website, :phone, :mobile, :fax, :email, :tax_code, :note, :account_number, :bank],
                associated_against: {
                  city: [:name],
                  state: [:name],
                  agents: [:name]
                },
                using: {
                  tsearch: {
                    dictionary: 'english',
                    any_word: true,
                    prefix: true
                  }
                }

  def self.full_text_search(q, user)
    result = self.all
    if !user.can?(:view_all_customers, Contact)
      result = result.where(user_id: user.id)
    end

    q.split(" ").each do |k|
      result = result.where("LOWER(contacts.cache_search) LIKE ?", "%#{k.strip.downcase}%")
    end

    result = result.limit(50).map {|model| {:id => model.id, :text => model.short_name} }
  end

  def short_name
    name.gsub(/công ty /i,'').gsub(/TNHH /i,'').gsub(/cổ phần /i,'')
  end

  def full_address
    return fixed_address if fixed_address.present?

    ad = ""
    if city.present?
      ad += ", "+city.name_with_state
    end
    ad = address+ad if address.present?

    return ad
  end

  def agent_list_html
    html = ""
    if !agents.nil?
      agents.each do |agent|
        html += '<div class="agent-line">'
        html += agent.html_agent_line.html_safe
        html += '</div>'
      end
    end

    return html
  end

  def update_cache
    types = contact_types.map{|t| t.id}
    types_cache = types.empty? ? "" : "["+types.join("][")+"]"
    self.update_attribute(:contact_types_cache, types_cache)
  end

  def logo_path(version = nil)
    if self.image_url.nil?
      return "public/img/avatar.jpg"
    elsif !version.nil?
      return self.image_url(version)
    else
      return self.image_url
    end
  end

  def logo(version = nil)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers

    link_helper.url_for(controller: "contacts", action: "logo", id: self.id, type: version)
  end

  def update_cache_search
    str = []
    str << name
    str << name.to_s.downcase.strip
    # str << address.to_s.downcase.strip if address.to_s.strip.present?
    str << website.to_s.downcase.strip if website.to_s.strip.present?
    str << phone.to_s.downcase.strip if phone.to_s.strip.present?
    str << mobile.to_s.downcase.strip if mobile.to_s.strip.present?
    str << fax.to_s.downcase.strip if fax.to_s.strip.present?
    str << email.to_s.downcase.strip if email.to_s.strip.present?
    str << tax_code.to_s.downcase.strip if tax_code.to_s.strip.present?
    str << note.to_s.downcase.strip if note.to_s.strip.present?
    str << account_number.to_s.downcase.strip if account_number.to_s.strip.present?
    str << bank.to_s.downcase.strip if bank.to_s.strip.present?

    # str << city.name.to_s.downcase.strip if city.present?
    # str << state.name.to_s.downcase.strip if state.present?

    agents.each do |a|
      str << a.name.to_s.downcase.strip
      str << a.phone.to_s.downcase.strip if a.phone.to_s.strip.present?
      str << a.email.to_s.downcase.strip if a.email.to_s.strip.present?
    end

    companies.each do |c|
      c.update_cache_search
    end

    self.update_column(:cache_search, str.join(" ") + " " + str.join(" ").unaccent)
  end
end
