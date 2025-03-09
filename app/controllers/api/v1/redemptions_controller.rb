class Api::V1::RedemptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reward, only: [:create]
  before_action :set_redemption, only: [:destroy]

  # GET /api/v1/redemptions
  def index
    redemptions = current_user.redemptions.includes(:reward).order(created_at: :desc)
    render json: { success: true, data: redemptions.as_json(include: :reward), errors: [] }, status: :ok
  end

  # POST /api/v1/redemptions
  def create
    service = RedemptionCreationService.new(current_user, @reward)
    result = service.call

    if result[:success]
      render json: { success: true, data: result[:data].as_json(include: :reward), errors: [] }, status: :created
    else
      render json: { success: false, data: nil, errors: result[:errors] }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/redemptions/:id
  def destroy
    if @redemption.destroy
      render json: { success: true, data: nil, errors: [] }, status: :no_content
    else
      render json: { success: false, data: nil, errors: @redemption.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  private

  def redemption_params
    params.require(:redemption).permit(:reward_id)
  end

  # Finds the reward based on the reward_id provided in the redemption payload.
  def set_reward
    @reward = Reward.find_by(id: redemption_params[:reward_id])
    render json: { success: false, data: nil, errors: ['Reward not found'] }, status: :not_found unless @reward
  end

  # Finds the redemption belonging to the current user.
  def set_redemption
    @redemption = current_user.redemptions.find_by(id: params[:id])
    render json: { success: false, data: nil, errors: ['Redemption not found'] }, status: :not_found unless @redemption
  end
end
