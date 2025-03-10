class Api::V1::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :check_if_admin, only: [:update_user_points]
  before_action :set_user, only: [:update_user_points]

  def points
    render json: { points: current_user.points }, status: :ok
  end

  def update_user_points
    if @user.update(points: params[:points])
      render json: { message: "User's points updated successfully to #{@user.points} points" }
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find_by(id: params[:user_id])
    render json: { errors: ['User not found'] }, status: :unprocessable_entity unless @user
  end
end
