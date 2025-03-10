require 'rails_helper'

RSpec.describe 'Api::V1::Redemptions', type: :request do
  # Helper method to generate a JWT token for a given user.
  def auth_headers_for(user)
    token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)[0]
    { 'Authorization' => "Bearer #{token}", 'Content-Type' => 'application/json' }
  end

  let(:user) do
    User.create!(
      email: 'test@example.com',
      password: 'password',
      password_confirmation: 'password',
      points: 150,
      jti: SecureRandom.uuid
    )
  end

  describe 'GET /api/v1/redemptions' do
    context 'with date filters' do
      before do
        reward = Reward.create!(title: 'Reward B', description: 'Desc B', points_cost: 100)
        # Create three redemptions with different created_at dates.
        user.redemptions.create!(reward: reward, discounted_points: 100, created_at: Date.new(2025, 3, 1))
        user.redemptions.create!(reward: reward, discounted_points: 100, created_at: Date.new(2025, 3, 15))
        user.redemptions.create!(reward: reward, discounted_points: 100, created_at: Date.new(2025, 3, 31))
      end

      it 'returns redemptions within the given date range' do
        get '/api/v1/redemptions', params: { from_date: '01-03-2025', to_date: '20-03-2025' },
                                   headers: auth_headers_for(user)
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        # With our conversion, redemptions on 2025-03-01 and 2025-03-15 fall within the range.
        expect(json_response['data'].size).to eq(2)
      end
    end
  end

  describe 'POST /api/v1/redemptions' do
    let(:reward) { Reward.create!(title: 'Reward C', description: 'Desc C', points_cost: 100) }

    context 'when user has sufficient points' do
      before { user.update(points: 150) }

      it 'creates a redemption' do
        post '/api/v1/redemptions', params: { redemption: { reward_id: reward.id } }.to_json,
                                    headers: auth_headers_for(user)
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['data']['reward']).to eq(reward.title)
      end
    end

    context 'when user does not have enough points' do
      before { user.update(points: 50) }

      it 'returns an unprocessable entity status' do
        post '/api/v1/redemptions', params: { redemption: { reward_id: reward.id } }.to_json,
                                    headers: auth_headers_for(user)
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
        expect(json_response['errors']).to include('User does not have enough points')
      end
    end

    context 'when reward is not found' do
      it 'returns a not found status' do
        post '/api/v1/redemptions', params: { redemption: { reward_id: 9999 } }.to_json, headers: auth_headers_for(user)
        # Your controller returns 404 if reward is not found
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include('Reward not found')
      end
    end
  end

  describe 'DELETE /api/v1/redemptions/:id' do
    context 'when redemption exists' do
      let!(:redemption) do
        reward = Reward.create!(title: 'Reward D', description: 'Desc D', points_cost: 100)
        user.redemptions.create!(reward: reward, discounted_points: 100)
      end

      it 'attempts to destroy the redemption and returns unprocessable entity if callback fails' do
        # If after_destroy callback fails, deletion might return 422
        delete "/api/v1/redemptions/#{redemption.id}", headers: auth_headers_for(user)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
