# frozen_string_literal: true

module Users
  # Registrations Controller
  class RegistrationsController < Devise::RegistrationsController
    respond_to :json
    # before_action :configure_sign_up_params, only: [:create]
    # before_action :configure_account_update_params, only: [:update]

    # GET /resource/sign_up
    # def new
    #   super
    # end

    # POST /resource

    # @!method create
    #   Handles user registration.
    #   Builds and saves a new user resource with the provided sign-up parameters.
    #   If the resource is persisted, returns the user's ID and email in JSON format with a status of :created.
    #   Otherwise, returns validation errors in JSON format with a status of :unprocessable_entity.
    #   @yield [resource] Yields the resource if a block is given.
    #   @return [void]

    def create
      build_resource(sign_up_params)
      resource.save
      yield resource if block_given?
      resource.persisted? ? handle_success : handle_failure
    end
    # GET /resource/edit
    # def edit
    #   super
    # end

    # PUT /resource
    # def update
    #   super
    # end

    # DELETE /resource
    # def destroy
    #   super
    # end

    # GET /resource/cancel
    # Forces the session data which is usually expired after sign
    # in to be expired now. This is useful if the user wants to
    # cancel oauth signing in/up in the middle of the process,
    # removing all OAuth session data.
    # def cancel
    #   super
    # end
    private

    def handle_success
      expire_data_after_sign_in! unless resource.active_for_authentication?
      render json: { data: { id: resource.id, email: resource.email } }, status: :created
    end

    def handle_failure
      clean_up_passwords(resource)
      set_minimum_password_length
      render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
    end

    # protected

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_sign_up_params
    #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
    # end

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_account_update_params
    #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
    # end

    # The path used after sign up.
    # def after_sign_up_path_for(resource)
    #   super(resource)
    # end

    # The path used after sign up for inactive accounts.
    # def after_inactive_sign_up_path_for(resource)
    #   super(resource)
    # end
  end
end
