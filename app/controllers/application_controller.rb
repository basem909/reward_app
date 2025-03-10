class ApplicationController < ActionController::API
  def check_if_admin
    return if current_user.admin?

    render json: { error: 'Only an admin can execute this action!' }, status: :unprocessable_entity
  end
end
