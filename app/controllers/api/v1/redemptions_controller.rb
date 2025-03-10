module Api
  module V1
    # Redemptions Controller
    class RedemptionsController < ApplicationController
      before_action :authenticate_user!
      before_action :check_if_admin, only: [:destroy]
      before_action :extract_date_params, only: [:index]
      before_action :set_reward, only: [:create]
      before_action :set_redemption, only: [:destroy]

      # GET /api/v1/redemptions
      #
      # Retrieves a collection of redemptions for the current user with optional date filters.
      #
      # @param [DateTime] from_date
      # @param [DateTime] to_date
      #
      # @return [Array<Hash>] A collection of redemptions for the current user.
      def index
        redemptions = collection_scope
        render json: { data: redemptions.map(&:redemption_formatter) }, status: :ok
      end

      # POST /api/v1/redemptions
      #
      # Creates a redemption for the current user.
      #
      # @param [Integer] reward_id
      #
      # @return [Hash] A hash containing a success flag, data, and errors.
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
      #
      # Deletes a redemption for the current user.
      #
      # @return [Hash] A hash containing a success flag, data, and errors.
      def destroy
        if @redemption.destroy
          render json: { success: true, data: nil, errors: [] }, status: :no_content
        else
          render json: { success: false, data: nil, errors: @redemption.errors.full_messages },
                 status: :unprocessable_entity
        end
      end

      private

      # @return [ActiveRecord::Relation] A scope of redemptions for the current user,
      #   filtered by the given date range, and ordered by created_at in descending order.
      def collection_scope
        current_user.redemptions.within_date_range(@from_date, @to_date).recent
      end

      # Extracts and sets instance variables for the given date params.
      #
      # Expects the date params to be in the format of 'dd-mm-yyyy'.
      #
      # @api private
      def extract_date_params
        if params[:from_date].present?
          from_date_str = params[:from_date].gsub(/\s+/, '')
          @from_date = Date.strptime(from_date_str, '%d-%m-%Y')
        end

        return unless params[:to_date].present?

        to_date_str = params[:to_date].gsub(/\s+/, '')
        # Use end_of_day so that the entire day is covered
        @to_date = Date.strptime(to_date_str, '%d-%m-%Y').end_of_day
      end

      # @return [ActionController::Parameters] A parameter object containing the reward_id
      #   from the given params.
      def redemption_params
        params.require(:redemption).permit(:reward_id)
      end

      # Finds a reward by the given reward_id from the given params and sets it to @reward.
      #
      # If the reward is not found, renders a JSON response with a success flag of false,
      #   data of nil, and errors of ['Reward not found'], and returns a not found status.
      def set_reward
        @reward = Reward.find_by(id: redemption_params[:reward_id])
        return if @reward

        render json: { success: false, data: nil, errors: ['Reward not found'] }, status: :not_found and return
      end

      # Finds a redemption by the given id from the given params and sets it to @redemption.
      #
      # If the redemption is not found, renders a JSON response with a success flag of false,
      #   data of nil, and errors of ['Redemption not found'], and returns a not found status.
      def set_redemption
        @redemption = current_user.redemptions.find_by(id: params[:id])
        return if @redemption

        render json: { success: false, data: nil, errors: ['Redemption not found'] }, status: :not_found and return
      end
    end
  end
end
