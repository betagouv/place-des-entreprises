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
      @record.in?(@user.antenne.received_needs) ||
      # Antenne régionale et ses antennes locales
      (@user.is_manager? && @record.in?(@user.antenne.perimeter_received_needs)) ||
      # Manager de plusieurs antennes
      (@user.is_manager? && (@record.expert_antennes.any? { |antenne| @user.managed_antennes.include?(antenne) }))
  end

  def show_need_actions?
    @record.matches.find_by(expert: @user.experts).present?
  end

  def add_match?
    admin?
  end

  def star?
    admin?
  end
end
