class HomeController < ApplicationController
  def index
    #code
  end
  
  def close_tab
    render layout: nil
  end
end
