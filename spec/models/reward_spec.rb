# spec/models/reward_spec.rb
require 'rails_helper'

RSpec.describe Reward, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:redemptions).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:redemptions) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:points_cost) }
    it { is_expected.to validate_numericality_of(:points_cost).only_integer.is_greater_than_or_equal_to(0) }
  end

  describe '#reward_formatter' do
    let(:reward) do
      Reward.create!(
        title: 'Test Reward',
        description: 'A sample description',
        points_cost: 100
      )
    end

    it 'returns a formatted hash with expected keys and values' do
      formatted = reward.reward_formatter
      expect(formatted).to be_a(Hash)
      expect(formatted[:id]).to eq(reward.id)
      expect(formatted[:title]).to eq(reward.title)
      expect(formatted[:description]).to eq(reward.description)
      expect(formatted[:points_cost]).to eq(reward.points_cost)
    end
  end
end
