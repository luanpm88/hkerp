class SalesDeliveryDetail < ActiveRecord::Base
  belongs_to :sales_delivery
  belongs_to :order_detail
end
