require 'rails_helper'

RSpec.describe 'Api::V1::Users', type: :request do
  # Helper method to generate a JWT token for a given user.
  def auth_headers_for(user)
    token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)[0]
    { 'Authorization' => "Bearer #{token}", 'Content-Type' => 'application/json' }
  end

  # Create a regular (non-admin) user to test the points endpoint.
  let(:regular_user) do
    User.create!(
      email: 'user@example.com',
      password: 'password',
      password_confirmation: 'password',
      points: 500,
      jti: SecureRandom.uuid,
      role: :user
    )
  end

  # Create an admin user for endpoints requiring admin privileges.
  let(:admin_user) do
    User.create!(
      email: 'admin@example.com',
      password: 'password',
      password_confirmation: 'password',
      points: 1000,
      jti: SecureRandom.uuid,
      role: :admin
    )
  end

  describe 'GET /api/v1/users/me/points' do
    it 'returns the points balance for the authenticated user' do
      get '/api/v1/users/me/points', headers: auth_headers_for(regular_user)
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['points']).to eq(regular_user.points)
    end

    it 'returns 401 if not authenticated' do
      get '/api/v1/users/me/points'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH /api/v1/users/update_user_points' do
    context 'when update fails due to invalid parameters' do
      it 'returns unprocessable entity' do
        patch '/api/v1/users/update_user_points',
              params: { user_id: regular_user.id, points: 'not_a_number' }.to_json,
              headers: auth_headers_for(admin_user)
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).not_to be_empty
      end
    end

    context 'when the requester is not an admin' do
      it 'returns unauthorized (unprocessable entity)' do
        patch '/api/v1/users/update_user_points',
              params: { user_id: regular_user.id, points: 600 }.to_json,
              headers: auth_headers_for(regular_user)
        # If your controller returns 422 for non-admin requests, adjust accordingly.
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when the user exists and update is valid' do
      it "updates the user's points successfully" do
        new_points = 750
        patch '/api/v1/users/update_user_points',
              params: { user_id: regular_user.id, points: new_points }.to_json,
              headers: auth_headers_for(admin_user)
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq("User's points updated successfully to #{new_points} points")
        expect(regular_user.reload.points).to eq(new_points)
      end
    end

    context 'when the user does not exist' do
      it 'returns an error' do
        patch '/api/v1/users/update_user_points',
              params: { user_id: 9999, points: 500 }.to_json,
              headers: auth_headers_for(admin_user)
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include('User not found')
      end
    end
  end
end
