class CreateRedemptionService
  def initialize(user, reward)
    @user = user
    @reward = reward
  end

  def call
    return insufficient_points_response unless sufficient_points?

    create_redemption_response
  rescue ActiveRecord::RecordInvalid => e
    failure_response(e.message)
  end

  private

  # Check if the user has enough points for the reward.
  def sufficient_points?
    @user.can_redeem?(@reward)
  end

  # Returns a failure hash if the user doesn't have enough points.
  def insufficient_points_response
    { success: false, errors: ['User does not have enough points'], data: nil }
  end

  # Deduct points and create the redemption record inside a transaction.
  def create_redemption_response
    redemption = nil
    ActiveRecord::Base.transaction do
      deduct_points
      redemption = create_redemption
    end
    { success: true, errors: [], data: redemption }
  end

  # Deduct the reward's cost from the user's points.
  def deduct_points
    @user.update!(points: @user.points - @reward.points_cost)
  end

  # Create a redemption record with the appropriate discounted points.
  def create_redemption
    @user.redemptions.create!(reward: @reward, discounted_points: @reward.points_cost)
  end

  # Returns a failure response with errors.
  def failure_response(error_message)
    { success: false, errors: [error_message], data: nil }
  end
end
