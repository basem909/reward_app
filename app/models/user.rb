require 'devise'
require 'devise/orm/active_record'

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :redemptions, dependent: :destroy
  has_many :rewards, through: :redemptions

  # Returns true if the user has enough points to redeem the given reward
  def can_redeem?(reward)
    points >= reward.points_cost
  end
end
