require 'rails_helper'

RSpec.describe CreateRedemptionService, type: :service do
  let(:reward_cost) { 100 }
  let(:reward) { Reward.create!(title: "Test Reward", description: "Sample description", points_cost: reward_cost) }

  describe '#call' do
    context 'when the user does not have enough points' do
      before do
        @user = User.create!(email: "low@example.com", password: "password", password_confirmation: "password", points: 50, jti: SecureRandom.uuid)
      end

      subject { described_class.new(@user, reward).call }

      it 'returns a failure response with insufficient points error' do
        expect(subject[:success]).to be false
        expect(subject[:errors]).to include('User does not have enough points')
        expect(subject[:data]).to be_nil
      end
    end

    context 'when the user has enough points' do
      before do
        @user = User.create!(email: "enough@example.com", password: "password", password_confirmation: "password", points: 150, jti: SecureRandom.uuid)
      end

      subject { described_class.new(@user, reward).call }

      it 'returns a success response with redemption data' do
        response = subject
        expect(response[:success]).to be true
        expect(response[:errors]).to be_empty
        redemption = response[:data]
        expect(redemption).to be_a(Redemption)
        expect(redemption.discounted_points).to eq(reward_cost)
      end

      it 'deducts the reward cost from the user points' do
        expect { described_class.new(@user, reward).call }.to change { @user.reload.points }.by(-reward_cost)
      end
    end

    context 'when a record invalid error is raised during creation' do
      before do
        @user = User.create!(email: "error@example.com", password: "password", password_confirmation: "password", points: 150, jti: SecureRandom.uuid)
      end

      subject { described_class.new(@user, reward) }

      before do
        allow(@user.redemptions).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(Redemption.new))
      end

      it 'returns a failure response with the error message' do
        response = subject.call
        expect(response[:success]).to be false
        expect(response[:data]).to be_nil
        expect(response[:errors]).not_to be_empty
      end
    end
  end
end
