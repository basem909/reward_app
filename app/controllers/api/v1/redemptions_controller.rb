class Api::V1::RedemptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :extract_date_params, only: [:index]
  before_action :set_reward, only: [:create]
  before_action :set_redemption, only: [:destroy]

  # GET /api/v1/redemptions
  def index
    redemptions = collection_scope
    render json: { data: redemptions.map(&:redemption_formatter) }, status: :ok
  end

  # POST /api/v1/redemptions
  def create
    service = CreateRedemptionService.new(current_user, @reward)
    result = service.call

    if result[:success]
      render json: { success: true, data: result[:data].redemption_formatter, errors: [] }, status: :created
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

  def collection_scope
    current_user.redemptions.within_date_range(@from_date, @to_date).recent
  end

  def extract_date_params
    @from_date = params[:from_date]
    @to_date = params[:to_date]
  end

  def redemption_params
    params.require(:redemption).permit(:reward_id)
  end

  def set_reward
    @reward = Reward.find_by(id: redemption_params[:reward_id])
    render json: { success: false, data: nil, errors: ['Reward not found'] }, status: :not_found unless @reward
  end

  def set_redemption
    @redemption = current_user.redemptions.find_by(id: params[:id])
    render json: { success: false, data: nil, errors: ['Redemption not found'] }, status: :not_found unless @redemption
  end
end
