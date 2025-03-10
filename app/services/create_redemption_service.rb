# Service object to create a redemption record for a user.
class CreateRedemptionService
  # Returns a new instance of CreateRedemptionService.
  #
  # @param user [User] the user who is redeeming the reward
  # @param reward [Reward] the reward being redeemed
  def initialize(user, reward)
    @user = user
    @reward = reward
  end

  # Attempts to create a redemption for the user.
  #
  # Returns a failure response if the user's points are insufficient.
  # If redemption creation raises an ActiveRecord::RecordInvalid error, captures the exception
  # and returns a failure response with the error message.
  #
  # @return [Hash] the response indicating success or failure, with associated data or errors.

  def call
    return insufficient_points_response unless sufficient_points?

    create_redemption_response
  rescue ActiveRecord::RecordInvalid => e
    failure_response(e.message)
  end

  private

  # Check if the user has enough points for the reward.

  # Check if the user has enough points for the reward.
  #
  # @return [TrueClass, FalseClass] whether the user has enough points or not
  def sufficient_points?
    @user.can_redeem?(@reward)
  end

  # Returns a failure hash if the user doesn't have enough points.

  # Returns a hash indicating failure due to insufficient points.
  #
  # @return [Hash] a hash containing success status as false, an error message,
  #   and nil data.

  def insufficient_points_response
    { success: false, errors: ['User does not have enough points'], data: nil }
  end

  # Deduct points and create the redemption record inside a transaction.

  # Creates a redemption for the user within a database transaction.
  #
  # Deducts the reward's point cost from the user's points and creates a redemption record.
  # Returns a success response with the created redemption if successful.
  #
  # @return [Hash] a hash containing success status as true, no errors, and the created redemption data.

  def create_redemption_response
    redemption = nil
    ActiveRecord::Base.transaction do
      deduct_points
      redemption = create_redemption
    end
    { success: true, errors: [], data: redemption }
  end

  # Deduct the reward's cost from the user's points.

  # Deducts the reward's cost from the user's points.
  #
  # Updates the user's points by subtracting the reward's point cost.
  def deduct_points
    @user.update!(points: @user.points - @reward.points_cost)
  end

  # Create a redemption record with the appropriate discounted points.

  # Creates a redemption record for the user with the reward and appropriate discounted points.
  #
  # @return [Redemption] the created redemption record
  def create_redemption
    @user.redemptions.create!(reward: @reward, discounted_points: @reward.points_cost)
  end

  # Returns a failure response with errors.
  # Returns a failure response with the provided error message.
  #
  # @param [String] error_message the error message to be included in the response
  # @return [Hash] a hash containing success status as false, the error message, and nil data

  def failure_response(error_message)
    { success: false, errors: [error_message], data: nil }
  end
end
