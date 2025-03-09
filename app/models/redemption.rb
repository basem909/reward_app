class Redemption < ApplicationRecord
  belongs_to :user
  belongs_to :reward

  validate :user_has_enough_points, on: :create

  private

  def user_has_enough_points
    return unless user && reward

    return unless user.points < reward.points_cost

    errors.add(:base, 'User does not have enough points to redeem this reward.')
  end
end
