require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  test "Order's cache_total must be equal order's total" do
    Order.all.each do |o|
      assert o.cache_total == o.total
    end
  end
end
