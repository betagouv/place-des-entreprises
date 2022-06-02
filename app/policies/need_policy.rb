class NeedPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.is_admin?
        scope.all
      else
        scope.received_by(user)
      end
    end
  end

  def show?
    admin? ||
      @record.advisor == @user ||
      support?(@user, @record) ||
      @record.advisor_antenne == @user.antenne ||
      @record.in?(@user&.received_needs) ||
      (@user.is_manager? && @record.in?(@user.antenne.perimeter_received_needs))
  end

  def show_need_actions?
    @record.matches.find_by(expert: @user.experts).present?
  end

  def archive?
    admin?
  end
end
