module Api
  module V1
    class UsersController < ApplicationController
      before_action :authenticate_user!
      before_action :check_if_admin, only: [:update_user_points]
      before_action :set_user, only: [:update_user_points]

      # GET /api/v1/users/me/points
      # Retrieves current user's points.
      #
      # @return [Hash] A hash containing the user's points.
      # @return [Integer] points The user's points.
      def points
        render json: { points: current_user.points }, status: :ok
      end

      # PATCH /api/v1/users/update_user_points
      # Updates the points for a specific user. Requires admin privileges.
      #
      # @param [Integer] user_id The user to update.
      # @param [Integer] points The new points for the user.
      def update_user_points
        if @user.update(points: params[:points])
          render json: { message: "User's points updated successfully to #{@user.points} points" }
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      # Sets the @user instance variable using the user_id parameter.
      # If the user is not found, renders a JSON error response with status unprocessable_entity.

      def set_user
        @user = User.find_by(id: params[:user_id])
        render json: { errors: ['User not found'] }, status: :unprocessable_entity unless @user
      end
    end
  end
end
