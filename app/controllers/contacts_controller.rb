class ContactsController < ApplicationController
  include ContactsHelper
  
  load_and_authorize_resource
  before_action :set_contact, only: [:contact, :ajax_edit, :ajax_update, :show, :edit, :update, :destroy, :ajax_destroy, :ajax_show, :ajax_list_agent, :ajax_list_supplier_agent]

  # GET /contacts
  # GET /contacts.json
  def index
    @types = [ContactType.customer, ContactType.supplier]
    
    respond_to do |format|
      format.html
      format.json {
        render json: Contact.full_text_search(params[:q], current_user)
      }
    end
  end

  def individual
    @types = [ContactType.customer, ContactType.supplier]
    
    respond_to do |format|
      format.html
      format.json {
        render json: Contact.full_text_search(params[:q], current_user)
      }
    end
  end

  def company
    @types = [ContactType.customer, ContactType.supplier]
    
    respond_to do |format|
      format.html
      format.json {
        render json: Contact.company_search(params[:q], current_user)
      }
    end
  end

  # GET /contacts/1
  # GET /contacts/1.json
  def show
    if params[:tab_page].present?
      render layout: "content"
    else
      render layout: "none"
    end
  end

  # GET /contacts/new
  def new
    @contact = Contact.new
    
    if (!params[:type_id].nil?)
      @contact.contact_types << ContactType.find_by_id(params[:type_id])
    end
    if (!params[:company_id].nil?)
      @contact.companies << Contact.find_by_id(params[:company_id])
    end
    
    if params[:tab_page].present?
      render layout: "content"
    end
  end

  # GET /contacts/1/edit
  def edit    
  end

  # POST /contacts
  # POST /contacts.json
  def create
    @contact = Contact.new(contact_params)
    @contact.user_id = current_user.id

    respond_to do |format|
      if @contact.save       
        format.html { redirect_to params[:tab_page].present? ? {action: "show",id: @contact.id,tab_page: 1} : contacts_url, notice: 'Contact was successfully created.' }
        format.json { render action: 'show', status: :created, location: @contact }
      else
        format.html { render action: 'new', tab_page: params[:tab_page] }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contacts/1
  # PATCH/PUT /contacts/1.json
  def update
    params[:contact][:contact_type_ids] ||= []
    
    respond_to do |format|
      if @contact.update(contact_params)
        format.html { redirect_to params[:tab_page].present? ? {action: "show",id: @contact.id,tab_page: 1} : contacts_url, notice: 'Contact was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', tab_page: params[:tab_page] }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    @contact.destroy
    respond_to do |format|
      format.html { redirect_to contacts_url }
      format.json { head :no_content }
    end
  end
  
  def import    
    @result = Contact.import(params[:file])

  end
  
  def ajax_new    
    @contact = Contact.new
    
    if (!params[:type_id].nil?)
      @contact.contact_types << ContactType.find_by_id(params[:type_id])
    end
    if (!params[:company_id].nil?)
      @contact.companies << Contact.find_by_id(params[:company_id])
    end
    
    render :layout => nil
  end
  
  def ajax_edit
    
    render :layout => nil
  end
  
  # PATCH/PUT /contacts/1
  # PATCH/PUT /contacts/1.json
  def ajax_update
    params[:contact][:contact_type_ids] ||= []
    
    respond_to do |format|
      if @contact.update(contact_params)
        format.html { render action: 'ajax_show', :layout => nil, :id => @contact.id }
        format.json { head :no_content }
      else
        format.html { render action: 'ajax_edit' }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def ajax_create
    @contact = Contact.new(contact_params)
    @contact.user_id = current_user.id

    respond_to do |format|
      if @contact.save
        format.html { render action: 'ajax_show', :layout => nil, :id => @contact.id }
        format.json { head :no_content }
      else
        format.html { render action: 'ajax_new', :layout => nil }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # DELETE /contacts/1
  def ajax_destroy
    @contact.destroy
    
    render :nothing => true
  end
  
    
  # GET /orders/1
  # GET /orders/1.json
  def ajax_show
    @contact.address = @contact.full_address
    render :json => @contact.to_json
  end
  
  def ajax_list_agent
    render :layout => nil
  end
  
  def ajax_list_supplier_agent
    render :layout => nil
  end
  
  def datatable
    result = Contact.datatable(params, current_user)
    
    result[:items].each_with_index do |item, index|
      actions = render_contacts_actions(item)
      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end
  
  def logo
    send_file @contact.logo_path(params[:type]), :disposition => 'inline'
  end
  
  def inactive
    respond_to do |format|
      if @contact.set_inactive
        format.html { redirect_to params[:tab_page].present? ? contacts_url(tab_page: 1) : contacts_url, notice: 'Contact was successfully trashed.' }
        format.json { render action: 'show', status: :created, location: @contact }
      else
        format.html { redirect_to params[:tab_page].present? ? contacts_url(tab_page: 1) : contacts_url, alert: 'Contact was unsuccessfully trashed.' }
        format.json { render action: 'show', status: :created, location: @contact }
      end
    end
  end
  
  def active
    respond_to do |format|
      if @contact.set_active
        format.html { redirect_to params[:tab_page].present? ? contacts_url(tab_page: 1) : contacts_url, notice: 'Contact was successfully trashed.' }
        format.json { render action: 'show', status: :created, location: @contact }
      else
        format.html { redirect_to params[:tab_page].present? ? contacts_url(tab_page: 1) : contacts_url, alert: 'Contact was unsuccessfully trashed.' }
        format.json { render action: 'show', status: :created, location: @contact }
      end
    end
  end
  
  def top_buyers
    require 'rubyXL/convenience_methods/worksheet'
    require 'rubyXL/convenience_methods/cell'

    authorize! :top_buyers, Contact
    
    workbook = RubyXL::Parser.parse('templates/TopBuyers.xlsx')
    
    # Last 6 months
    worksheet = workbook[0]      
    iIndex = 4
    count = 1
    
    worksheet[1][4].change_contents(ContactStat.sum(:buy_last_6_months))
    ContactStat.where.not(contact_id: 1).where('buy_last_6_months > 0').order('buy_last_6_months desc').each do |stat|          
        # insert product
        worksheet.insert_row(iIndex)
        worksheet[iIndex][0].change_contents(stat.contact.id.to_s)
        worksheet[iIndex][1].change_contents(stat.contact.name)
        worksheet[iIndex][2].change_contents(stat.contact.tex_info_line)
        worksheet[iIndex][3].change_contents(stat.contact.agent_list_text)
        worksheet[iIndex][4].change_contents(stat.buy_last_6_months)
        worksheet[iIndex][5].change_contents(stat.updated_at.strftime("%F"))
        
        # increment count
        count += 1
        iIndex += 1
    end
    
    worksheet.delete_row(iIndex-2)
    worksheet.delete_row(iIndex-1)
    
    # Last 1 year
    worksheet = workbook[1]      
    iIndex = 4
    count = 1
    
    worksheet[1][4].change_contents(ContactStat.sum(:buy_last_1_year))
    ContactStat.where.not(contact_id: 1).where('buy_last_1_year > 0').order('buy_last_1_year desc').each do |stat|          
        # insert product
        worksheet.insert_row(iIndex)
        worksheet[iIndex][0].change_contents(stat.contact.id.to_s)
        worksheet[iIndex][1].change_contents(stat.contact.name)
        worksheet[iIndex][2].change_contents(stat.contact.tex_info_line)
        worksheet[iIndex][3].change_contents(stat.contact.agent_list_text)
        worksheet[iIndex][4].change_contents(stat.buy_last_1_year)
        worksheet[iIndex][5].change_contents(stat.updated_at.strftime("%F"))
        
        # increment count
        count += 1
        iIndex += 1
    end
    
    worksheet.delete_row(iIndex-2)
    worksheet.delete_row(iIndex-1)
    
    # Last 3 years
    worksheet = workbook[2]      
    iIndex = 4
    count = 1
    
    worksheet[1][4].change_contents(ContactStat.sum(:buy_last_3_years))
    ContactStat.where.not(contact_id: 1).where('buy_last_3_years > 0').order('buy_last_3_years desc').each do |stat|          
        # insert product
        worksheet.insert_row(iIndex)
        worksheet[iIndex][0].change_contents(stat.contact.id.to_s)
        worksheet[iIndex][1].change_contents(stat.contact.name)
        worksheet[iIndex][2].change_contents(stat.contact.tex_info_line)
        worksheet[iIndex][3].change_contents(stat.contact.agent_list_text)
        worksheet[iIndex][4].change_contents(stat.buy_last_3_years)
        worksheet[iIndex][5].change_contents(stat.updated_at.strftime("%F"))
        
        # increment count
        count += 1
        iIndex += 1
    end
    
    worksheet.delete_row(iIndex-2)
    worksheet.delete_row(iIndex-1)
    
    # All times
    worksheet = workbook[3]      
    iIndex = 4
    count = 1
    
    worksheet[1][4].change_contents(ContactStat.sum(:buy_all_time))
    ContactStat.where.not(contact_id: 1).where('buy_all_time > 0').order('buy_all_time desc').each do |stat|          
        # insert product
        worksheet.insert_row(iIndex)
        worksheet[iIndex][0].change_contents(stat.contact.id.to_s)
        worksheet[iIndex][1].change_contents(stat.contact.name)
        worksheet[iIndex][2].change_contents(stat.contact.tex_info_line)
        worksheet[iIndex][3].change_contents(stat.contact.agent_list_text)
        worksheet[iIndex][4].change_contents(stat.buy_all_time)
        worksheet[iIndex][5].change_contents(stat.updated_at.strftime("%F"))
        
        # increment count
        count += 1
        iIndex += 1
    end
    
    worksheet.delete_row(iIndex-2)
    worksheet.delete_row(iIndex-1)
    
    send_data workbook.stream.string,
        filename: "TopBuyers.xlsx",
        disposition: 'attachment'
  end
  
  def not_buy_customers
    authorize! :not_buy_customers, Contact
    
    require 'rubyXL/convenience_methods/worksheet'
    require 'rubyXL/convenience_methods/cell'

    workbook = RubyXL::Parser.parse('templates/NotBuyCustomers.xlsx')
    
    # Last 6 months
    worksheet = workbook[0]      
    iIndex = 4
    count = 1
    
    worksheet[1][4].change_contents(ContactStat.sum(:buy_last_6_months))
    ContactStat.includes(:contact).where.not(contact_id: 1).where('buy_last_6_months = 0').where('buy_all_time > 0').order('contacts.name').each do |stat|          
        # insert product
        worksheet.insert_row(iIndex)
        worksheet[iIndex][0].change_contents(count)
        worksheet[iIndex][1].change_contents(stat.contact.name)
        worksheet[iIndex][2].change_contents(stat.contact.tex_info_line)
        worksheet[iIndex][3].change_contents(stat.contact.agent_list_text)
        worksheet[iIndex][4].change_contents(stat.buy_last_6_months)
        worksheet[iIndex][5].change_contents(stat.updated_at.strftime("%F"))
        
        # increment count
        count += 1
        iIndex += 1
    end
    
    worksheet.delete_row(iIndex-2)
    worksheet.delete_row(iIndex-1)
    
    # Last 1 year
    worksheet = workbook[1]      
    iIndex = 4
    count = 1
    
    worksheet[1][4].change_contents(ContactStat.sum(:buy_last_1_year))
    ContactStat.includes(:contact).where.not(contact_id: 1).where('buy_last_1_year = 0').where('buy_all_time > 0').order('contacts.name').each do |stat|          
        # insert product
        worksheet.insert_row(iIndex)
        worksheet[iIndex][0].change_contents(count)
        worksheet[iIndex][1].change_contents(stat.contact.name)
        worksheet[iIndex][2].change_contents(stat.contact.tex_info_line)
        worksheet[iIndex][3].change_contents(stat.contact.agent_list_text)
        worksheet[iIndex][4].change_contents(stat.buy_last_1_year)
        worksheet[iIndex][5].change_contents(stat.updated_at.strftime("%F"))
        
        # increment count
        count += 1
        iIndex += 1
    end
    
    worksheet.delete_row(iIndex-2)
    worksheet.delete_row(iIndex-1)
    
    # Last 3 years
    worksheet = workbook[2]      
    iIndex = 4
    count = 1
    
    worksheet[1][4].change_contents(ContactStat.sum(:buy_last_3_years))
    ContactStat.includes(:contact).where.not(contact_id: 1).where('buy_last_3_years = 0').where('buy_all_time > 0').order('contacts.name').each do |stat|          
        # insert product
        worksheet.insert_row(iIndex)
        worksheet[iIndex][0].change_contents(count)
        worksheet[iIndex][1].change_contents(stat.contact.name)
        worksheet[iIndex][2].change_contents(stat.contact.tex_info_line)
        worksheet[iIndex][3].change_contents(stat.contact.agent_list_text)
        worksheet[iIndex][4].change_contents(stat.buy_last_3_years)
        worksheet[iIndex][5].change_contents(stat.updated_at.strftime("%F"))
        
        # increment count
        count += 1
        iIndex += 1
    end
    
    worksheet.delete_row(iIndex-2)
    worksheet.delete_row(iIndex-1)
    
    # All times
    worksheet = workbook[3]      
    iIndex = 4
    count = 1
    
    worksheet[1][4].change_contents(ContactStat.sum(:buy_all_time))
    ContactStat.includes(:contact).where.not(contact_id: 1).where('buy_all_time = 0').order('contacts.name').each do |stat|          
        # insert product
        worksheet.insert_row(iIndex)
        worksheet[iIndex][0].change_contents(count)
        worksheet[iIndex][1].change_contents(stat.contact.name)
        worksheet[iIndex][2].change_contents(stat.contact.tex_info_line)
        worksheet[iIndex][3].change_contents(stat.contact.agent_list_text)
        worksheet[iIndex][4].change_contents(stat.buy_all_time)
        worksheet[iIndex][5].change_contents(stat.updated_at.strftime("%F"))
        
        # increment count
        count += 1
        iIndex += 1
    end
    
    worksheet.delete_row(iIndex-2)
    worksheet.delete_row(iIndex-1)
    
    send_data workbook.stream.string,
        filename: "NotReturnCustomers.xlsx",
        disposition: 'attachment'
  end

  def report

  end

  def report_export_
    require 'rubyXL/convenience_methods/worksheet'
    require 'rubyXL/convenience_methods/cell'

    authorize! :top_buyers, Contact

    if params[:from_date].present? && params[:to_date].present?
      @from_date = params[:from_date].to_date.beginning_of_day
      @to_date =  params[:to_date].to_date.end_of_day
    else
      @from_date = DateTime.now.beginning_of_month
      @to_date =  DateTime.now.end_of_day
    end

    @contacts = Contact.customers.where('created_at > ?', @from_date.beginning_of_day).where('created_at < ?', @to_date.end_of_day).order('created_at desc')
    
    workbook = RubyXL::Parser.parse('templates/NewContacts.xlsx')    
    
    # Last 6 months
    worksheet = workbook[0]

    # Begin
    worksheet[0][0].change_contents("Khách hàng mới từ ngày #{@from_date.strftime("%Y-%m-%d")} đến ngày #{@to_date.strftime("%Y-%m-%d")}")

    iIndex = 4
    count = 1
    @contacts.each do |contact|          
        # insert product
        worksheet.insert_row(iIndex)
        worksheet[iIndex][0].change_contents(count)
        worksheet[iIndex][1].change_contents(contact.name)
        # worksheet[iIndex][2].change_contents(contact.tex_info_line)
        # worksheet[iIndex][3].change_contents(contact.agent_list_text)
        worksheet[iIndex][2].change_contents(contact.contact_stat.buy_all_time)
        worksheet[iIndex][3].change_contents(contact.created_at.strftime("%F"))
        
        # increment count
        count += 1
        iIndex += 1
    end

    worksheet[1][1].change_contents(@contacts.count)

    worksheet.delete_row(3)
    
    send_data workbook.stream.string,
        filename: "NewContacts-#{@from_date.strftime("%Y-%m-%d")}-#{@to_date.strftime("%Y-%m-%d")}.xlsx",
        disposition: 'attachment'
  end

  def report_export
    require 'rubyXL/convenience_methods/worksheet'
    require 'rubyXL/convenience_methods/cell'

    authorize! :top_buyers, Contact

    if params[:from_date].present? && params[:to_date].present?
      @from_date = params[:from_date].to_date.beginning_of_day
      @to_date =  params[:to_date].to_date.end_of_day
    else
      @from_date = DateTime.now.beginning_of_month
      @to_date =  DateTime.now.end_of_day
    end

    @contacts = Contact.customers.where('created_at > ?', @from_date.beginning_of_day).where('created_at < ?', @to_date.end_of_day).order('created_at desc')
    
    workbook = RubyXL::Parser.parse('templates/NewContactsEmailPhone.xlsx')    
    
    # Last 6 months
    worksheet = workbook[0]

    # Begin
    worksheet[0][0].change_contents("Khách hàng mới từ ngày #{@from_date.strftime("%Y-%m-%d")} đến ngày #{@to_date.strftime("%Y-%m-%d")}")

    iIndex = 4
    count = 1
    @contacts.each do |contact|          
        # insert product
        worksheet.insert_row(iIndex)
        worksheet[iIndex][0].change_contents(count)
        worksheet[iIndex][1].change_contents(contact.name)
        worksheet[iIndex][2].change_contents(contact.email)
        worksheet[iIndex][3].change_contents(contact.phone)
        worksheet[iIndex][2].change_contents(contact.contact_stat.buy_all_time)
        worksheet[iIndex][3].change_contents(contact.created_at.strftime("%F"))
        
        # increment count
        count += 1
        iIndex += 1
    end

    worksheet[1][1].change_contents(@contacts.count)

    worksheet.delete_row(3)
    
    send_data workbook.stream.string,
        filename: "NewContacts-#{@from_date.strftime("%Y-%m-%d")}-#{@to_date.strftime("%Y-%m-%d")}.xlsx",
        disposition: 'attachment'
  end

  def report_not_buy_from
    require 'rubyXL/convenience_methods/worksheet'
    require 'rubyXL/convenience_methods/cell'

    authorize! :top_buyers, Contact

    if params[:from_date].present?
      @from_date = params[:from_date].to_date.beginning_of_day
    else
      @from_date = DateTime.now.beginning_of_month
    end

    @contacts = Contact.customers_not_buy_from(@from_date.beginning_of_day)

    puts @from_date
    puts @contacts.count
    
    workbook = RubyXL::Parser.parse('templates/NotVisitContacts.xlsx')    
    
    # Last 6 months
    worksheet = workbook[0]

    # Begin
    worksheet[0][0].change_contents("Khách hàng không mua hàng từ ngày #{@from_date.strftime("%Y-%m-%d")} đến nay")

    iIndex = 4
    count = 1
    @contacts.each do |contact|       
        last_order = contact.customer_orders
          .where(parent_id: nil)
          .where(order_status_name: ["confirmed","finished"])
          .last
      
        # insert product
        worksheet.insert_row(iIndex)
        worksheet[iIndex][0].change_contents(count)
        worksheet[iIndex][1].change_contents(contact.name)
        worksheet[iIndex][2].change_contents(contact.email)
        worksheet[iIndex][3].change_contents(contact.phone)
        worksheet[iIndex][4].change_contents(contact.tex_info_line)
        worksheet[iIndex][5].change_contents(contact.agent_list_text)
        worksheet[iIndex][6].change_contents(contact.contact_stat.buy_all_time)
        worksheet[iIndex][7].change_contents(
          last_order.present? ? last_order.created_at.strftime("%F") : "N/A"
        )
        
        # increment count
        count += 1
        iIndex += 1
    end

    worksheet[1][1].change_contents(@contacts.count)

    worksheet.delete_row(3)
    
    send_data workbook.stream.string,
        filename: "NotVisitContacts-#{@from_date.strftime("%Y-%m-%d")}.xlsx",
        disposition: 'attachment'
  end

  def supplier_export
    require 'rubyXL/convenience_methods/worksheet'
    require 'rubyXL/convenience_methods/cell'

    authorize! :top_buyers, Contact

    @contacts = Contact.suppliers
    
    workbook = RubyXL::Parser.parse('templates/SupplierList.xlsx')    
    
    # Last 6 months
    worksheet = workbook[0]

    # Begin
    worksheet[0][0].change_contents("Danh sách NCC")

    iIndex = 4
    count = 1
    @contacts.each do |contact|       
        last_order = contact.customer_orders
          .where(parent_id: nil)
          .where(order_status_name: ["confirmed","finished"])
          .last
      
        # insert product
        worksheet.insert_row(iIndex)
        worksheet[iIndex][0].change_contents(count)
        worksheet[iIndex][1].change_contents(contact.name)
        worksheet[iIndex][2].change_contents(contact.email)
        worksheet[iIndex][3].change_contents(contact.phone)
        worksheet[iIndex][4].change_contents(contact.tex_info_line)
        worksheet[iIndex][5].change_contents(contact.agent_list_text)
        
        # increment count
        count += 1
        iIndex += 1
    end

    worksheet[1][1].change_contents(@contacts.count)

    worksheet.delete_row(3)
    
    send_data workbook.stream.string,
        filename: "SupplierList.xlsx",
        disposition: 'attachment'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contact
      @contact = Contact.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contact_params
      params.require(:contact).permit(:fixed_address, :image, :city_id, :website, :name, :phone, :mobile, :fax, :email, :address, :tax_code, :note, :account_number, :bank, :contact_type_id, :parent_ids => [], :agent_ids => [], :company_ids => [], :contact_type_ids => [])
    end
end
