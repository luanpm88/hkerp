class OrdersController < ApplicationController
  include ApplicationHelper

  load_and_authorize_resource :except => [:order_actions, :datatable]

  before_action :set_order, only: [:order_actions, :print_order_fix1, :print_order_fix2, :print_order_fix3, :update_tip, :do_update_tip,  :order_log, :finish_order, :update_info, :do_update_info, :confirm_price, :do_update_price, :update_price, :do_change, :change, :pdf_preview, :show, :edit, :update, :destroy, :download_pdf, :print_order, :confirm_order]

  # GET /orders
  # GET /orders.json
  def index
    #Find Customer orders
    @orders = Order.customer_orders

    render layout: "content" if params[:tab_page].present?
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    @hk = @order.supplier

    render layout: "content"
  end

  # GET /orders/new
  def new
      @order = Order.new
      @order.order_date = (Time.now).strftime("%Y-%m-%d")
      @order.order_deadline = (Time.now + 7.days).strftime("%Y-%m-%d")
      #@order.payment_deadline = (Time.now + 3.days).strftime("%Y-%m-%d")
      @order.debt_date = (Time.now + 7.days).strftime("%Y-%m-%d")
      @order.debt_days = ((Time.now + 7.days).to_date - Time.now.to_date).to_i
      @order.shipping_date = (Time.now).strftime("%Y-%m-%d")
      @order.warranty_place = "Tận nơi"
      @order.warranty_cost = "0"

      @order.payment_method_id = -1

      if !params[:purchase].nil?
        @order.customer = Contact.HK
      else
        @order.supplier = Contact.HK
      end

  end

  # GET /orders/1/edit
  def edit
      @order.order_date = (@order.order_date).strftime("%Y-%m-%d")
      @order.order_deadline = (@order.order_deadline).strftime("%Y-%m-%d")
      #@order.payment_deadline = (@order.payment_deadline).strftime("%Y-%m-%d")
      @order.debt_date = (@order.debt_date).strftime("%Y-%m-%d") if !@order.debt_date.nil?
      @order.debt_days = (@order.debt_date.to_date - @order.order_date.to_date).to_i if !@order.debt_date.nil?
      @order.shipping_date = (@order.shipping_date).strftime("%Y-%m-%d")
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(order_params)

    @order.create_quotation_code

    if @order.is_purchase
      @order.purchaser = current_user
    end
    if @order.is_sales
      @order.salesperson = current_user
    end

    order_details_params = params[:order_details]
    if !order_details_params.nil?
        order_details_params.each do |line|
        od = OrderDetail.new(permit_order_detail_params(line[1]))
        @order.order_details << od
      end
    end

    p @order.order_details

    list_path = @order.is_purchase ? purchase_orders_orders_path : orders_path
    respond_to do |format|
      if @order.save
        @order.set_status('new', current_user)
        if !@order.is_purchase
          format.html { redirect_to params[:tab_page].present? ? {action: "show", id: @order.id, tab_page:1} : list_path, notice: 'Order was successfully created.' }
          format.json { render action: 'show', status: :created, location: @order }
        else
          format.html { redirect_to params[:tab_page].present? ? {action: "show", id: @order.id, tab_page:1} : purchase_orders_orders_path, notice: 'Order was successfully created.' }
          format.json { render action: 'show', status: :created, location: @order }
        end
      else
        format.html { render action: 'new', tab_page: params[:tab_page] }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    list_path = @order.is_purchase ? purchase_orders_orders_path : orders_path
    @order.save_draft(current_user)
      respond_to do |format|
        if @order.update(order_params)
          @order.update_order_details(permit_order_details_params(params[:order_details]))

          if !params[:confirm].nil?
            format.html { redirect_to params[:tab_page].present? ? {action: "show", id: @order.id, tab_page:1} : confirm_order_orders_url(id: @order.id) }
            format.json { head :no_content }
          else
            format.html { redirect_to params[:tab_page].present? ? {action: "show", id: @order.id, tab_page:1} : list_path, notice: 'Order was successfully updated.' }
            format.json { head :no_content }
          end
        else
          format.html { render action: 'edit', tab_page: params[:tab_page] }
          format.json { render json: @order.errors, status: :unprocessable_entity }
        end
      end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url(tab_page: 1) }
      format.json { head :no_content }
    end
  end

  def download_pdf
    @hk = @order.supplier

    render  :pdf => "order_"+@order.quotation_code,
            :template => 'orders/show.pdf.erb',
            :layout => nil,
            :zoom => 1.2,
            :footer => {
               :center => "",
               :left => "",
               :right => "",
               :page_size => "A4",
               :margin  => {:top    => 0, # default 10 (mm)
                          :bottom => 0,
                          :left   => 0,
                          :right  => 0},
            }
  end

  def pdf_preview
    @hk = @order.supplier

    if params[:language] == 'en'
        render layout: nil, template: 'orders/_show_en.html.erb'
    else
        render layout: nil, template: 'orders/_show.html.erb'
    end
  end

  def print_order
    authorize! :read, @order

    @hk = @order.supplier
    render  :pdf => "quotation_"+@order.quotation_code,
            :template => 'orders/print_order.pdf.erb',
            :layout => nil,
            :zoom => 2,
            :footer => {
                :center => "",
                :left => "",
                :right => "",
                :page_size => "A4",
                :margin  => {:top    => 0, # default 10 (mm)
                          :bottom => 0,
                          :left   => 0,
                          :right  => 0},
            }

    #render layout: false
  end

  def print_order_fix1
    authorize! :read, @order

    @hk = @order.supplier
    render  :pdf => "fix1_quotation_"+@order.quotation_code,
            :template => 'orders/print_order_fix1.pdf.erb',
            :layout => nil,
            :zoom => 2,
            :footer => {
                :center => "",
                :left => "",
                :right => "",
                :page_size => "A4",
                :margin  => {:top    => 0, # default 10 (mm)
                          :bottom => 0,
                          :left   => 0,
                          :right  => 0},
            }

    #render layout: false
  end

  def print_order_fix2
    authorize! :read, @order

    @hk = @order.supplier
    render  :pdf => "fix2_quotation_"+@order.quotation_code,
            :template => 'orders/print_order_fix2.pdf.erb',
            :layout => nil,
            :zoom => 2,
            :footer => {
                :center => "",
                :left => "",
                :right => "",
                :page_size => "A4",
                :margin  => {:top    => 0, # default 10 (mm)
                          :bottom => 0,
                          :left   => 0,
                          :right  => 0},
            }

    #render layout: false
  end

  def print_order_fix3
    authorize! :read, @order

    @hk = @order.supplier
    render  :pdf => "fix3_quotation_"+@order.quotation_code,
            :template => 'orders/print_order_fix3.pdf.erb',
            :layout => nil,
            :zoom => 2,
            :footer => {
                :center => "",
                :left => "",
                :right => "",
                :page_size => "A4",
                :margin  => {:top    => 0, # default 10 (mm)
                          :bottom => 0,
                          :left   => 0,
                          :right  => 0},
            }

    #render layout: false
  end

  def purchase_orders
    #Find Customer orders
    @orders = Order.purchase_orders

    render layout: "content" if params[:tab_page].present?
  end

  def confirm_order
    @order.save_draft(current_user)

    list_path = @order.is_purchase ? purchase_orders_orders_path : orders_path
    respond_to do |format|
      if @order.confirm_order(current_user)
        format.html { redirect_to params[:tab_page].present? ? {action: "show", id: @order.id, tab_page:1} : list_path, notice: 'Order was successfully confimed.' }
        format.json { head :no_content }
      else
        format.html { redirect_to edit_order_path(@order, tab_page: params[:tab_page]), alert: 'Order was unsuccessfully confimed. Check the order again.' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def cancel_order
    @order.save_draft(current_user)

    list_path = @order.is_purchase ? purchase_orders_orders_path : orders_path
    respond_to do |format|
      if @order.cancel_order(current_user)
        format.html { redirect_to params[:tab_page].present? ? {action: "show", id: @order.id, tab_page:1} : list_path, notice: 'Order was successfully confimed.' }
        format.json { head :no_content }
      else
        format.html { redirect_to edit_order_path(@order, tab_page: params[:tab_page]), alert: 'Order was unsuccessfully confimed. Check the order again.' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def confirm_items
    list_path = @order.is_purchase ? purchase_orders_orders_path : orders_path

    respond_to do |format|
      if @order.confirm_items(current_user)
        format.html { redirect_to  params[:tab_page].present? ? {action: "show", id: @order.id, tab_page:1} : list_path, notice: 'Order Items was successfully confimed.' }
        format.json { head :no_content }
      else
        format.html { redirect_to edit_order_path(@order, tab_page: params[:tab_page]), alert: 'Order Items was unsuccessfully confimed. Check the order again.' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def confirm_price
    respond_to do |format|
      if @order.confirm_price(current_user)
        format.html { redirect_to params[:tab_page].present? ? {action: "show", id: @order.id, tab_page:1} : pricing_orders_orders_url, notice: 'Order Prices was successfully confimed.' }
        format.json { head :no_content }
      else
        format.html { redirect_to update_price_orders_url(id: @order.id, tab_page: 1), alert: 'Order Price was unsuccessfully confimed. Check the prices again.' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def finish_order
    @order.save_draft(current_user)

    respond_to do |format|
      if @order.finish_order(current_user)
        return_url = {controller: "accounting", action: "orders"}
        format.html { redirect_to params[:tab_page].present? ? {action: "show", id: @order.id, tab_page:1} : return_url, notice: 'Order was successfully finished.' }
        format.json { head :no_content }
      else
        format.html { redirect_to update_info_orders_path(:id => @order.id, accounting: true, tab_page: params[:tab_page]), alert: 'Order was unsuccessfully finished. You must update printed order number.' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def datatable
    authorize! :view_list, Order

    result = Order.datatable(params, current_user)

    #result[:items].each_with_index do |item, index|
    #  actions = render_order_actions(item)
    #
    #  result[:result]["data"][index][result[:actions_col]] = actions
    #end

    render json: result[:result]
  end



  def change
    render layout: "content" if params[:tab_page].present?
  end

  def do_change
    @order.save_draft(current_user)
    respond_to do |format|
      if @order.update(order_params)

        if @order.is_purchase || !@order.is_prices_oudated
          @order.confirm_price(current_user)
        else
          @order.confirm_items(current_user)
        end

        @order.update_order_details(permit_order_details_params(params[:order_details]))

        format.html { redirect_to params[:tab_page].present? ? {action: "show", id: @order.id, tab_page:1} : orders_path, notice: 'Order was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'change', tab_page: params[:tab_page] }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end

  end

  def pricing_orders
    @orders = Order.pricing_orders(current_user)
  end

  def update_price

    render layout: "content" if params[:tab_page].present?
  end

  def do_update_price
    @order.save_draft(current_user)

    @order.update_attributes(purchaser_id: current_user.id)

    params[:order_details].each do |line|
      od = @order.order_details.find(line[0])
      od.product.update_price(line[1][:product], current_user)

      pp = Product.find(od.product.id)
      od.update_attribute(:product_price_id, pp.product_price.id)
      od.update_attribute(:price, line[1][:new_sell_price]) if line[1][:new_sell_price].present?
    end

    if !params[:product_parts].nil?
      params[:product_parts].each do |line|
        p = Product.find(line[0])
        p.update_price(line[1][:product], current_user)
      end
    end

    respond_to do |format|
      if !params[:confirm].nil?
        format.html { redirect_to confirm_price_orders_url(id: @order.id, tab_page: 1), alert: 'The prices was unsuccessfully updated.' }
      else
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : update_price_orders_url(id: @order.id), notice: 'The prices was successfully updated.' }
      end
      format.json { render action: 'show', status: :created, location: @order }
    end
  end

  def update_info
    @order.order_date = (@order.order_date).strftime("%Y-%m-%d")
    @order.order_deadline = (@order.order_deadline).strftime("%Y-%m-%d")
    #@order.payment_deadline = (@order.payment_deadline).strftime("%Y-%m-%d")
    @order.debt_date = (@order.debt_date).strftime("%Y-%m-%d") if !@order.debt_date.nil?
    @order.debt_days = (@order.debt_date.to_date - @order.order_date.to_date).to_i if !@order.debt_date.nil?
    @order.shipping_date = (@order.shipping_date).strftime("%Y-%m-%d")

    render layout: "content" if params[:tab_page].present?
  end

  def do_update_info
    if params[:page] == "accounting"
      redirect_url = {controller: "accounting", action: "orders"}
    else
      redirect_url = @order.is_purchase ? purchase_orders_orders_path : orders_path
    end

    @order.save_draft(current_user)

    respond_to do |format|
      if @order.update(update_info_params)
        @order.update_order_details_info(permit_order_details_params(params[:order_details]))
        format.html { redirect_to params[:tab_page].present? ? {action: "show", id: @order.id, tab_page:1} : redirect_url, notice: 'Order was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { redirect_to update_info_orders_url(id: @order.id, tab_page: params[:tab_page]), alert: 'Order was unsuccessfully updated. Check the information again.' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_tip
    render layout: "content" if params[:tab_page].present?
  end

  def do_update_tip
    @order.save_draft(current_user)

    return_url = {controller: "accounting", action: "orders"}
    respond_to do |format|
      if @order.update_order_detail_tips(permit_order_details_params(params[:order_details])) #@order.update(update_tip_params)

        format.html { redirect_to params[:tab_page].present? ? {action: "show", id: @order.id, tab_page:1} : return_url, notice: 'Order tip was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render "update_tip", tab_page: params[:tab_page] }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def order_log
    @logs = @order.order_log

    render layout: "content" if params[:tab_page].present?
  end

  def order_actions

    render layout: nil
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
      #@order.order_date = @order.order_date.strptime("%m/%d/%Y") if !@order.order_date.nil?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:customer_id, :supplier_id, :agent_id, :shipping_place, :payment_method_id, :payment_deadline, :buyer_name, :buyer_name, :buyer_company, :buyer_address, :buyer_tax_code, :buyer_phone, :buyer_fax, :buyer_email, :tax_id, :order_date,
                                    :order_deadline,
                                    :deposit,
                                    :shipping_date,
                                    :shipping_time,
                                    :warranty_place,
                                    :warranty_cost,
                                    :watermark,
                                    :debt_date,
                                    :customer_po,
                                    :printed_order_number,
                                    :supplier_agent_id,
                                    :tip_contact_id,
                                    :shipment_contact_id
                                  )
    end

    def update_info_params
      params.require(:order).permit(:agent_id, :shipping_place, :payment_method_id, :payment_deadline, :buyer_name, :buyer_name, :buyer_company, :buyer_address, :buyer_tax_code, :buyer_phone, :buyer_fax, :buyer_email, :tax_id, :order_date,
                                    :order_deadline,
                                    :deposit,
                                    :shipping_date,
                                    :shipping_time,
                                    :warranty_place,
                                    :warranty_cost,
                                    :watermark,
                                    :debt_date,
                                    :customer_po,
                                    :printed_order_number,
                                    :supplier_agent_id,
                                    :tip_contact_id,
                                    :shipment_contact_id
                                  )
    end

    def update_tip_params
      params.require(:order).permit(
                                    :tip_contact_id
                                  )
    end

    def permit_order_detail_params(params)
      params.permit(:tax_id,
                    :tip_amount,
                    :discount_amount,
                    :product_price_id,
                    :order_id,
                    :product_id,
                    :quantity,
                    :price,
                    :product_name,
                    :warranty,
                    :unit,
                    :product_description,
                    :shipment_amount
                  )
    end

    def permit_order_details_params(params)
      arr = []
      params.each do |line|
        arr << permit_order_detail_params(line[1])
      end

      return arr
    end
end
