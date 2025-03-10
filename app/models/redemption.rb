# frozen_string_literal: true

# Redemption model
class Redemption < ApplicationRecord
  belongs_to :user
  belongs_to :reward

  validate :user_has_enough_points, on: :create

  after_destroy :restore_user_points

  # Scope to include rewards and order by descending created_at.
  scope :recent, -> { includes(:reward).order(created_at: :desc) }

  # Scope to filter redemptions by an optional date range.
  scope :within_date_range, lambda { |from_date, to_date|
    scope = all
    scope = scope.where('created_at >= ?', from_date) if from_date.present?
    scope = scope.where('created_at <= ?', to_date) if to_date.present?
    scope
  }

  # Returns a formatted hash containing redemption details.
  #
  # @return [Hash] a hash with the following keys:
  #   - :id [Integer] the ID of the redemption
  #   - :user_email [String] the email of the user who made the redemption
  #   - :reward [String] the title of the reward
  #   - :discounted_points [Integer] the number of points deducted for the redemption

  def redemption_formatter
    {
      id: id,
      user_email: user.email,
      reward: reward.title,
      discounted_points: discounted_points
    }
  end

  private

  # Validates that the user has enough points to redeem the reward.
  #
  # This validation only occurs during creation and ensures that the user has
  # enough points to cover the reward's cost unless the `discounted_points`
  # attribute is already set (indicating that points have been deducted).
  #
  # If the user does not have enough points, an error is added to the base.
  #
  # @return [void]

  def user_has_enough_points
    return unless user && reward

    # Only validate if discounted_points is not set (i.e. zero or nil),
    # because once points are deducted and discounted_points is set, we assume it was valid.
    return unless (discounted_points.nil? || discounted_points.zero?) && user.points < reward.points_cost

    errors.add(:base, 'User does not have enough points to redeem this reward.')
  end

  # Restores the user's points after redemption is destroyed.
  #
  # This method is an after_destroy callback that ensures the user's points
  # are returned to their original value by adding back the points that were
  # deducted for the redemption.
  #
  # @return [void]

  def restore_user_points
    user.update(points: user.points + discounted_points)
  end
end
