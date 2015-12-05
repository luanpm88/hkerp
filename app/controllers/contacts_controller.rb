class ContactsController < ApplicationController
  include ContactsHelper
  
  load_and_authorize_resource
  before_action :set_contact, only: [:ajax_edit, :ajax_update, :show, :edit, :update, :destroy, :ajax_destroy, :ajax_show, :ajax_list_agent, :ajax_list_supplier_agent]

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
