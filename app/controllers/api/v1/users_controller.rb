class Api::V1::UsersController < ApplicationController
  before_action :authenticate_user!

  def points
    render json: { points: current_user.points }, status: :ok
  end

  def update_user_points
    if @user.update(points: params[:points])
      render json: { message: "User's points updated successfully to #{@user.points} points"}
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end


  private

  def set_user
    @user = User.find_by(id: params[:id])
    render json: { errors: ['User not found'] }, status: :unprocessable_entity unless @user
  end
end
