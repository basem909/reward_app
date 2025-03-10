module Users
  class SessionsController < Devise::SessionsController
    # Remove or comment out any respond_to call if present:
    # respond_to :json

    # Authenticates a user and signs them in, returning a JWT token.
    #
    # This method uses Warden to authenticate the user with the provided
    # authentication options. Upon successful authentication, the user is signed
    # in and a JWT token is retrieved from the request environment.
    # The method then renders a JSON response containing the user's id, email,
    # and the JWT token.
    #
    # @return [JSON] JSON response with user id, email, and JWT token.

    def create
      self.resource = warden.authenticate!(auth_options)
      sign_in(resource_name, resource)
      token = request.env['warden-jwt_auth.token']
      render json: { data: { id: resource.id, email: resource.email, token: token } }, status: :ok
    end

    # Signs out a user, revoking the JWT.
    #
    # This method simply signs out the user with Warden, and then calls the
    # `respond_to_on_destroy` method to handle the response.
    #
    # @return [JSON] JSON response with a success message.
    def destroy
      sign_out(resource_name)
      respond_to_on_destroy
    end

    protected

    # Override the default behavior so it doesn't call `respond_to`

    # Renders a JSON response with a success message upon a successful sign out.
    #
    # @return [JSON] JSON response with a success message.
    def respond_to_on_destroy
      render json: { message: 'Signed out successfully' }, status: :no_content
    end
  end
end
