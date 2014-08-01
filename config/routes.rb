Hkerp::Application.routes.draw do
  
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

  resources :supplier_order_details do
    collection do
      get :ajax_new
      post :ajax_create
      get :ajax_destroy
      get :ajax_edit
      patch :ajax_update
    end
  end

  resources :supplier_orders

  resources :roles

  resources :taxes

  resources :order_details do
    collection do
      get :ajax_new
      post :ajax_create
      get :ajax_destroy
      get :ajax_edit
      patch :ajax_update
    end
  end

  resources :payment_methods

  resources :orders do
    collection do
      get :download_pdf
      get :print_order
    end
  end

  devise_for :users
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
    end
  end

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
