class Api::V1::RewardsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_if_admin, only: [:destroy, :create, :update]
  before_action :set_reward, only: [:update, :destroy]

  def index
    rewards = collection_formatter(model_class.all)
    render json: { data: rewards }, status: :ok
  end

  def create
    reward = model_class.new(reward_params)
    if reward.save
      render json: { data: resource_formatter(reward) }, status: :created
    else
      render json: { errors: reward.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @reward.update(reward_params)
      render json: { data: resource_formatter(@reward) }, status: :ok
    else
      render json: { errors: @reward.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @reward.destroy
      head :no_content
    else
      render json: { errors: @reward.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def model_class
    Reward
  end

  def reward_params
    params.require(:reward).permit(:title, :description, :points_cost)
  end

  def set_reward
    @reward = model_class.find_by(id: params[:id])
    return if @reward

    render json: { errors: 'Reward not found' }, status: :not_found
  end

  def resource_formatter(reward)
    reward.reward_formatter
  end

  def collection_formatter(rewards)
    rewards.map(&:format_reward)
  end
end
