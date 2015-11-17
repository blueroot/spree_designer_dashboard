class DesignerAbility
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.has_role? "designer"
      #can :read, Product
    end
  end
end