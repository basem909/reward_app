require 'devise'
require 'devise/orm/active_record'

class User < ApplicationRecord
  # Include default devise modules.
  # Add :jwt_authenticatable with the JTIMatcher revocation strategy.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  # Include the JTIMatcher methods to handle token revocation
  include Devise::JWT::RevocationStrategies::JTIMatcher

  # Associations
  has_many :redemptions, dependent: :destroy
  has_many :rewards, through: :redemptions

  # Returns true if the user has enough points to redeem the given reward
  def can_redeem?(reward)
    points >= reward.points_cost
  end
end
