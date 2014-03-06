class ContactsController < ApplicationController
  before_action :set_contact, only: [:show, :edit, :update, :destroy, :ajax_destroy, :ajax_show, :ajax_list_agent]

  # GET /contacts
  # GET /contacts.json
  def index
    @contacts = Contact.main_contacts(type: params[:type])
  end

  # GET /contacts/1
  # GET /contacts/1.json
  def show
  end

  # GET /contacts/new
  def new
    @contact = Contact.new    
  end

  # GET /contacts/1/edit
  def edit
  end

  # POST /contacts
  # POST /contacts.json
  def create
    @contact = Contact.new(contact_params)

    respond_to do |format|
      if @contact.save       
        format.html { redirect_to contacts_url, notice: 'Contact was successfully created.' }
        format.json { render action: 'show', status: :created, location: @contact }
      else
        format.html { render action: 'new' }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contacts/1
  # PATCH/PUT /contacts/1.json
  def update
    respond_to do |format|
      if @contact.update(contact_params)
        format.html { redirect_to contacts_url, notice: 'Contact was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
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
  
  def ajax_show    
    render :layout => nil
  end
  
  def ajax_new    
    @contact = Contact.new
    
    if (!params[:type_id].nil?)
      @contact.contact_type = ContactType.find_by_id(params[:type_id])
    end
    if (!params[:company_id].nil?)
      @contact.companies << Contact.find_by_id(params[:company_id])
    end
    
    
    render :layout => nil
  end
  
  def ajax_create
    @contact = Contact.new(contact_params)

    respond_to do |format|
      if @contact.save
        format.html { render action: 'ajax_show', :layout => nil, :id => @contact.id }
        format.json { render action: 'show', status: :created, location: @contact }
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
    render :json => @contact.to_json
  end
  
  def ajax_list_agent
    render :layout => nil
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contact
      @contact = Contact.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contact_params
      params.require(:contact).permit(:name, :phone, :mobile, :fax, :email, :address, :tax_code, :note, :contact_type_id, :parent_ids => [], :agent_ids => [], :company_ids => [])
    end
end
