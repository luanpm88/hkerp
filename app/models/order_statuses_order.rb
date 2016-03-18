class OrderStatusesOrder < ActiveRecord::Base
  belongs_to :order
  belongs_to :order_status
  belongs_to :user
end
