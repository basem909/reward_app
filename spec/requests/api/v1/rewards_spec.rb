require 'rails_helper'

RSpec.describe "Api::V1::Rewards", type: :request do
  # Helper method to generate a JWT token for a given user.
  def auth_headers_for(user)
    token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)[0]
    { 'Authorization' => "Bearer #{token}", 'Content-Type' => 'application/json' }
  end

  # Create an admin user for endpoints requiring admin access.
  let(:admin) do
    User.create!(
      email: "admin@example.com",
      password: "password",
      password_confirmation: "password",
      points: 1000,
      role: :admin,
      jti: SecureRandom.uuid
    )
  end

  # Create a non-admin user for read-only endpoints.
  let(:user) do
    User.create!(
      email: "user@example.com",
      password: "password",
      password_confirmation: "password",
      points: 1000,
      role: :user,
      jti: SecureRandom.uuid
    )
  end

  describe "GET /api/v1/rewards" do
    before do
      Reward.create!(title: "Reward 1", description: "Desc 1", points_cost: 100)
      Reward.create!(title: "Reward 2", description: "Desc 2", points_cost: 200)
    end

    it "returns all rewards in formatted output" do
      get "/api/v1/rewards", headers: auth_headers_for(user)
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response["data"]).to be_an(Array)
      expect(json_response["data"].size).to eq(2)
      # Verify that each reward has the expected keys.
      expect(json_response["data"].first).to include("id", "title", "description", "points_cost")
    end
  end

  describe "POST /api/v1/rewards" do
    context "with valid parameters" do
      let(:valid_params) { { reward: { title: "New Reward", description: "New Desc", points_cost: 300 } } }

      it "creates a new reward" do
        post "/api/v1/rewards", params: valid_params.to_json, headers: auth_headers_for(admin)
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response["data"]).to include(
          "id" => a_kind_of(Integer),
          "title" => "New Reward",
          "description" => "New Desc",
          "points_cost" => 300
        )
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) { { reward: { description: "Missing title and points_cost" } } }

      it "returns unprocessable entity" do
        post "/api/v1/rewards", params: invalid_params.to_json, headers: auth_headers_for(admin)
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).not_to be_empty
      end
    end
  end

  describe "PATCH /api/v1/rewards/:id" do
    let!(:reward) { Reward.create!(title: "Old Title", description: "Old Desc", points_cost: 150) }

    context "with valid parameters" do
      let(:update_params) { { reward: { title: "Updated Title", points_cost: 175 } } }

      it "updates the reward" do
        patch "/api/v1/rewards/#{reward.id}", params: update_params.to_json, headers: auth_headers_for(admin)
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["data"]).to include(
          "id" => reward.id,
          "title" => "Updated Title",
          "points_cost" => 175
        )
      end
    end

    context "with invalid parameters" do
      let(:invalid_update_params) { { reward: { title: "", points_cost: -10 } } }

      it "returns unprocessable entity" do
        patch "/api/v1/rewards/#{reward.id}", params: invalid_update_params.to_json, headers: auth_headers_for(admin)
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).not_to be_empty
      end
    end
  end

  describe "DELETE /api/v1/rewards/:id" do
    context "when reward exists" do
      let!(:reward) { Reward.create!(title: "To Delete", description: "Delete Desc", points_cost: 200) }

      it "destroys the reward and returns no content" do
        delete "/api/v1/rewards/#{reward.id}", headers: auth_headers_for(admin)
        expect(response).to have_http_status(:no_content)
        expect(Reward.find_by(id: reward.id)).to be_nil
      end
    end

    context "when reward does not exist" do
      it "returns not found" do
        delete "/api/v1/rewards/9999", headers: auth_headers_for(admin)
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to eq("Reward not found")
      end
    end
  end
end
