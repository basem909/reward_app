require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:redemptions).dependent(:destroy) }
    it { is_expected.to have_many(:rewards).through(:redemptions) }
  end

  describe 'enums' do
    it 'defaults to the user role' do
      user = User.new(email: 'test@example.com', password: 'password', password_confirmation: 'password')
      expect(user.role).to eq('user')
      expect(user).to be_user
      expect(user).not_to be_admin
    end

    it 'allows setting the role to admin' do
      user = User.new(email: 'admin@example.com', password: 'password', password_confirmation: 'password', role: :admin)
      expect(user.role).to eq('admin')
      expect(user).to be_admin
    end
  end

  describe '#can_redeem?' do
    # We'll use a simple double for reward
    let(:reward) { double('Reward', points_cost: 100) }

    context 'when user has enough points' do
      let(:user) do
        User.create!(
          email: 'enough@example.com',
          password: 'password',
          password_confirmation: 'password',
          points: 150,
          jti: SecureRandom.uuid
        )
      end

      it 'returns true' do
        expect(user.can_redeem?(reward)).to be true
      end
    end

    context 'when user does not have enough points' do
      let(:user) do
        User.create!(
          email: 'not_enough@example.com',
          password: 'password',
          password_confirmation: 'password',
          points: 50,
          jti: SecureRandom.uuid
        )
      end

      it 'returns false' do
        expect(user.can_redeem?(reward)).to be false
      end
    end
  end
end
