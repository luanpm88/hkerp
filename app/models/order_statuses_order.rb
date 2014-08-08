class OrderStatusesOrder < ActiveRecord::Base
  belongs_to :orders
  belongs_to :order_statuses
end
