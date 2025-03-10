require 'devise'
require 'devise/orm/active_record'

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  include Devise::JWT::RevocationStrategies::JTIMatcher

  # Associations
  has_many :redemptions, dependent: :destroy
  has_many :rewards, through: :redemptions

  # Ensure points is a non-negative integer.
  validates :points, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Enum for roles: default (0) is user and 1 is admin
  enum role: { user: 0, admin: 1 }

  # Returns true if the user has enough points to redeem the given reward

/*************  ✨ Codeium Command ⭐  *************/
  # Determines if the user has sufficient points to redeem a specified reward.
  #
  # @param reward [Reward] The reward object to check against the user's points.
  # @return [Boolean] Returns true if the user's points are greater than or equal to the reward's points cost, false otherwise.

/******  37cf0799-7a78-4d09-9f2a-2d8baf857e6d  *******/
  def can_redeem?(reward)
    points >= reward.points_cost
  end
end
