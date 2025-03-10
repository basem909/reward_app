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

  def redemption_formatter
    {
      id: id,
      user_email: user.email,
      reward: reward.title,
      discounted_points: discounted_points
    }
  end

  private

  def user_has_enough_points
    return unless user && reward

    return unless user.points < reward.points_cost

    errors.add(:base, 'User does not have enough points to redeem this reward.')
  end

  def restore_user_points
    user.update(points: user.points + discounted_points)
  end
end
