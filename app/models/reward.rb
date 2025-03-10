# Reward Model
class Reward < ApplicationRecord
  has_many :redemptions, dependent: :destroy
  has_many :users, through: :redemptions

  validates :title, presence: true
  validates :points_cost, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Formats a single reward as a hash.
  #
  # @return [Hash] A hash containing the reward's id, title, description, and points_cost.
  def reward_formatter
    {
      id:,
      title:,
      description:,
      points_cost:
    }
  end
end
