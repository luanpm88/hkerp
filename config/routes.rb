Hkerp::Application.routes.draw do
  resources :commission_programs do
    collection do
      get :start
      get :stop
      
      get :statistics
    end
  end
  
  resources :city_types
  resources :cities
  resources :states
  resources :countries
  resources :autotask_details

  resources :autotasks

  resources :product_stock_updates

  resources :combination_details

  resources :combinations

  resources :product_parts

  default_url_options :host => "27.0.15.181:3000"
  
  resources :product_prices

  resources :payment_records do
    collection do
      get :download_pdf
      get :pay_tip
      post :do_pay_tip
      
      get :pay_custom
      post :do_pay_custom
      
      get :trash
      get :custom_payments
      get :datatable
      
      get :edit_pay_custom
      get :statistics
      
      get :pay_commission
      post :do_pay_commission
    end
  end

  resources :delivery_details

  resources :deliveries do
    collection do
      get :deliver
      get :download_pdf
      get :trash
    end
  end


  resources :sales_deliveries do
    collection do
      get :deliver
      get :download_pdf
    end
  end

  resources :notifications do
    collection do
      get :read_notification
      get :update_notification
    end
  end

  resources :order_statuses

  resources :checkinout_requests do
    collection do
      get :approve
    end
  end

  get 'home/index'

  resources :checkinouts do
    collection do
      post :import
      get :import
      get :detail
    end
  end


  resources :roles

  resources :taxes

  resources :order_details do
    collection do
      get :ajax_new
      post :ajax_create
      delete :ajax_destroy
      get :ajax_edit
      patch :ajax_update
    end
  end

  resources :payment_methods

  resources :orders do
    collection do
      get :download_pdf
      get :print_order
      get :print_order_fix1
      get :purchase_orders
      get :confirm_order
      get :datatable
      get :pdf_preview
      get :change
      patch :do_change
      get :confirm_items
      
      get :pricing_orders
      get :update_price
      patch :do_update_price
      get :confirm_price
      
      get :update_info
      patch :do_update_info
      
      get :finish_order
      
      get :order_log
      
      get :update_tip
      patch :do_update_tip
    end
  end

  devise_for :users
  scope "/admin" do
    resources :users do
      collection do
        get :backup
        post :backup
        
        get :download_backup
        get :delete_backup
      end
    end
  end
  
  resources :users do
    collection do
      get :avatar
    end
  end
  
  resources :manufacturers

  resources :contact_types

  resources :contacts do
    collection do
      post :import
      get :ajax_new
      post :ajax_create
      get :ajax_show
      get :ajax_destroy
      get :ajax_show
      get :ajax_list_agent
      get :ajax_list_supplier_agent
      
      get :datatable
    end
  end

  resources :parent_categories

  resources :categories

  get 'admin' => 'admin#index'
  
  controller :sessions do
    get 'login' => :new
    post 'login' => :create
    delete 'logout' => :destroy
  end

  resources :products do
    collection do
      get :ajax_show
      get :ajax_new
      post :ajax_create
      get :datatable
      get :sales_delivery
      get :update_price
      patch :do_update_price
      
      patch :trash
      patch :un_trash
      
      get :statistics
      get :ajax_product_prices
      
      get :product_log
    end
  end
  
  resources :accounting do
    collection do
      get :orders
      get :pay
      
      get :statistic_sales
      get :statistic_purchase
    end
  end

  get '/accountings', to: 'accounting#index', as: 'accountings'
  get '/accountings/orders', to: 'accounting#orders', as: 'orders_accountings'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'home#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
