module ApplicationHelper
  def format_price number
    number_to_currency(number, precision: 0, unit: '', delimiter: ".")
  end
end
