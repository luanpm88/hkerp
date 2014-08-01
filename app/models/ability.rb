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
      can :read, :all
      can :read_attendances, User do |u|
        u.id == user.id || user.has_role?("attendance_manager")
      end
      can :create, CheckinoutRequest
      can :destroy, CheckinoutRequest do |request|
        request.user_id == user.id && request.status == 0
      end
      can :update, CheckinoutRequest do |request|
        request.user_id == user.id && request.status == 0
      end
      
      if user.has_role? "attendance_manager"
        #can :manage, Checkinout
        #can :manage, CheckinoutRequest
      end
      #can :manage, Checkinout
      #can :update, Comment do |comment|
      #  comment.try(:user) == user || user.role?(:moderator)
      #end
      #if user.role?(:author)
      #  can :create, Article
      #  can :update, Article do |article|
      #    article.try(:user) == user
      #  end
      #end
    end

  end
end
