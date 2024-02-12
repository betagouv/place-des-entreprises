class ApplicationController < SharedController
  # Abstract Controller for the App pages
  # implicitly uses the 'application' layout

  before_action :authenticate_user!
  before_action :fetch_themes, if: :devise_controller?

  def authenticate_admin!
    current_user.is_admin? || not_found
  end

  ## Devise overrides
  def after_sign_in_path_for(resource_or_scope)
    path = if resource_or_scope.sign_in_count == 1
      tutoriels_path
    elsif resource_or_scope.is_manager?
      reports_path
    elsif resource_or_scope.is_admin?
      conseiller_solicitations_path
    else
      quo_active_needs_path
    end
    stored_location_for(resource_or_scope) || path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
end
