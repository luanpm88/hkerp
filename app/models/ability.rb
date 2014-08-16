class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
    
    # Handle the case where we don't have a current_user i.e. the user is a guest
    user ||= User.new

    # Define a few sample abilities
    # cannot :destroy, Contact
    # cannot :manage , Comment
    # can    :read   , Tag , released: true
    
    #can :manage, Order, :salesperson_id => user.id
    #can :manage, SupplierOrder, :salesperson_id => user.id
    
    if user.has_role? "admin"
      can :manage, :all
    else
      can :read, Checkinout
      can :read_attendances, User do |u|
        u.id == user.id || user.has_role?("attendance_manager")
      end
      can :read, Contact
      can :create, Contact
      can :update, Contact do |contact|
        contact.user_id == user.id
      end
      
      can :read, Product
      can :create, Product
      can :update, Product do |product|
        product.user_id == user.id
      end
      
      #permissions for personal attandence requests
      can :create, CheckinoutRequest
      can :read, CheckinoutRequest do |request|
        request.user_id == user.id
      end
      can :destroy, CheckinoutRequest do |request|
        request.user_id == user.id && request.status == 0
      end
      can :update, CheckinoutRequest do |request|
        request.user_id == user.id && request.status == 0
      end
      
      if user.has_role? "attendance_manager"
        can :manage, Checkinout
        can :manage, CheckinoutRequest
      end
      
      if user.has_role? "salesperson"
        can :manage, Product
        can :manage, Manufacturer
        can :manage, Category
        can :manage, Contact
        
        can :create, Order
        can :read, Order do |order|
          order.salesperson_id == user.id
        end
        can :update, Order do |order|
          order.salesperson_id == user.id && order.status.name == 'quotation'
        end
        can :destroy, Order do |order|
          order.salesperson_id == user.id && order.status.name == 'quotation'
        end
        
        can :create, OrderDetail
        can :read, OrderDetail do |order_detail|
          order_detail.order.salesperson_id == user.id
        end
        can :update, OrderDetail do |order_detail|
          order_detail.order.salesperson_id == user.id && order_detail.order.status.name == 'quotation'
        end
        can :destroy, OrderDetail do |order_detail|
          order_detail.order.salesperson_id == user.id && order_detail.order.status.name == 'quotation'
        end
      end

    end

  end
end
