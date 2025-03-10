module Api
  module V1
    class RewardsController < ApplicationController
      before_action :authenticate_user!
      before_action :check_if_admin, only: [:destroy, :create, :update]
      before_action :set_reward, only: [:update, :destroy]

      # GET /api/v1/rewards
      #
      # Retrieves all rewards.
      #
      # @return [Object] A JSON response with a data key containing an array of rewards,
      #   and a status of :ok.

      def index
        rewards = collection_formatter(model_class.all)
        render json: { data: rewards }, status: :ok
      end

      # POST /api/v1/rewards
      #
      # Creates a new reward. Only accessible by admin users.
      #
      # @param [String] title
      # @param [String] description
      # @param [Integer] points_cost
      #
      # @return [Hash] A hash containing a success flag, data, and errors.
      def create
        reward = model_class.new(reward_params)
        if reward.save
          render json: { data: resource_formatter(reward) }, status: :created
        else
          render json: { errors: reward.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/rewards/:id
      #
      # Updates an existing reward. Only accessible by admin users.
      #
      # @param [String] title
      # @param [String] description
      # @param [Integer] points_cost
      #
      # @return [Hash] A hash containing a success flag, data, and errors.
      def update
        if @reward.update(reward_params)
          render json: { data: resource_formatter(@reward) }, status: :ok
        else
          render json: { errors: @reward.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/rewards/:id
      #
      # Deletes an existing reward. Only accessible by admin users.
      #
      # @return [Hash] A hash containing a success flag and errors.
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

      # Whitelists the reward parameters for strong parameters.

      # @return [ActionController::Parameters] The whitelisted parameters.
      def reward_params
        params.require(:reward).permit(:title, :description, :points_cost)
      end

      # Finds a reward by the given ID from the params and sets it to @reward.
      #
      # If the reward is not found, renders a JSON response with a success flag of
      # false, data of nil, and errors of ['Reward not found'], and returns a not
      # found status.
      def set_reward
        @reward = model_class.find_by(id: params[:id])
        return if @reward

        render json: { errors: 'Reward not found' }, status: :not_found
      end

      # Formats a single reward as a hash.
      #
      # @param [Reward] reward The reward to format.
      #
      # @return [Hash] A hash containing the reward's id, title, description, and points_cost.
      def resource_formatter(reward)
        reward.reward_formatter
      end

      # Formats a collection of rewards as an array of hashes.
      #
      # @param [Enumerable<Reward>] rewards The rewards to format.
      #
      # @return [Array<Hash>] An array of hashes containing each reward's id, title, description, and points_cost.
      def collection_formatter(rewards)
        rewards.map(&:reward_formatter)
      end
    end
  end
end
