class Api::V1::RedemptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_if_admin, only: [:destroy]
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
    if params[:from_date].present?
      from_date_str = params[:from_date].gsub(/\s+/, '') # removes extra spaces, e.g. "01- 03 - 2025" -> "01-03-2025"
      @from_date = Date.strptime(from_date_str, '%d-%m-%Y').strftime('%Y-%m-%d')
    end

    return unless params[:to_date].present?

    to_date_str = params[:to_date].gsub(/\s+/, '')
    @to_date = Date.strptime(to_date_str, '%d-%m-%Y').strftime('%Y-%m-%d')
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
