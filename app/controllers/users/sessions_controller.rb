module Users
  class SessionsController < Devise::SessionsController
    # Remove or comment out any respond_to call if present:
    # respond_to :json

    def create
      self.resource = warden.authenticate!(auth_options)
      sign_in(resource_name, resource)
      token = request.env['warden-jwt_auth.token']
      render json: { data: { id: resource.id, email: resource.email, token: token } }, status: :ok
    end

    def destroy
      sign_out(resource_name)
      respond_to_on_destroy
    end

    protected

    # Override the default behavior so it doesn't call `respond_to`
    def respond_to_on_destroy
      render json: { message: 'Signed out successfully' }, status: :no_content
    end
  end
end
