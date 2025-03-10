# Application Controller
class ApplicationController < ActionController::API
  # Before actions for admin only endpoints. Checks if the user is an admin.
  # If not, renders a 422 error with a message.
  def check_if_admin
    return if current_user.admin?

    render json: { error: 'Only an admin can execute this action!' }, status: :unprocessable_entity
  end
end
