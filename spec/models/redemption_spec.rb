require 'rails_helper'

RSpec.describe Redemption, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:reward) }
  end

  describe 'validations' do
    context 'when the user does not have enough points' do
      before do
        @user = User.create!(email: 'user1@example.com', password: 'password', points: 50, jti: SecureRandom.uuid)
        @reward = Reward.create!(title: 'Test Reward', description: 'A sample reward', points_cost: 100)
      end

      subject { Redemption.new(user: @user, reward: @reward, discounted_points: @reward.points_cost) }

      it 'is not valid' do
        expect(subject).not_to be_valid
        expect(subject.errors[:base]).to include('User does not have enough points to redeem this reward.')
      end
    end

    context 'when the user has enough points' do
      before do
        @user = User.create!(email: 'user2@example.com', password: 'password', points: 150, jti: SecureRandom.uuid)
        @reward = Reward.create!(title: 'Test Reward', description: 'A sample reward', points_cost: 100)
      end

      subject { Redemption.new(user: @user, reward: @reward, discounted_points: @reward.points_cost) }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end
  end

  describe 'callbacks' do
    describe 'after_destroy :restore_user_points' do
      before do
        @user = User.create!(email: 'user3@example.com', password: 'password', points: 50, jti: SecureRandom.uuid)
        @reward = Reward.create!(title: 'Test Reward', description: 'A sample reward', points_cost: 30)
        @redemption = Redemption.create!(user: @user, reward: @reward, discounted_points: 30)
      end

      it 'restores the user points after destruction' do
        initial_points = @user.points
        @redemption.destroy
        @user.reload
        expect(@user.points).to eq(initial_points + @redemption.discounted_points)
      end
    end
  end

  describe 'scopes' do
    describe '.recent' do
      before do
        @user_a = User.create!(email: 'user4@example.com', password: 'password', points: 200, jti: SecureRandom.uuid)
        @reward_a = Reward.create!(title: 'Reward1', description: 'Desc1', points_cost: 50)
        @redemption1 = Redemption.create!(user: @user_a, reward: @reward_a, discounted_points: 50, created_at: 2.days.ago)
        @redemption2 = Redemption.create!(user: @user_a, reward: @reward_a, discounted_points: 50, created_at: 1.day.ago)
      end

      it 'returns redemptions ordered by created_at in descending order' do
        expect(Redemption.recent.first).to eq(@redemption2)
        expect(Redemption.recent.last).to eq(@redemption1)
      end
    end

    describe '.within_date_range' do
      before do
        @user_b = User.create!(email: 'user5@example.com', password: 'password', points: 200, jti: SecureRandom.uuid)
        @reward_b = Reward.create!(title: 'Reward2', description: 'Desc2', points_cost: 50)
        @redemption1 = Redemption.create!(user: @user_b, reward: @reward_b, discounted_points: 50, created_at: '2025-03-01')
        @redemption2 = Redemption.create!(user: @user_b, reward: @reward_b, discounted_points: 50, created_at: '2025-03-15')
        @redemption3 = Redemption.create!(user: @user_b, reward: @reward_b, discounted_points: 50, created_at: '2025-03-31')
      end

      it 'returns redemptions within the given date range' do
        results = Redemption.within_date_range('2025-03-10', '2025-03-20')
        expect(results).to include(@redemption2)
        expect(results).not_to include(@redemption1, @redemption3)
      end

      it 'filters redemptions with only a starting date' do
        results = Redemption.within_date_range('2025-03-20', nil)
        expect(results).to include(@redemption3)
        expect(results).not_to include(@redemption1, @redemption2)
      end

      it 'filters redemptions with only an ending date' do
        results = Redemption.within_date_range(nil, '2025-03-10')
        expect(results).to include(@redemption1)
        expect(results).not_to include(@redemption2, @redemption3)
      end
    end
  end

  describe '#redemption_formatter' do
    before do
      @user = User.create!(email: 'user6@example.com', password: 'password', points: 200, jti: SecureRandom.uuid)
      @reward = Reward.create!(title: 'Formatted Reward', description: 'Test description', points_cost: 100)
      @redemption = Redemption.create!(user: @user, reward: @reward, discounted_points: 100)
    end

    it 'returns a formatted hash with expected keys and values' do
      formatted = @redemption.redemption_formatter
      expect(formatted).to eq({
        id: @redemption.id,
        user_email: @user.email,
        reward: @reward.title,
        discounted_points: @redemption.discounted_points
      })
    end
  end
end
