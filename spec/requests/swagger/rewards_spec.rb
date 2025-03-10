require 'swagger_helper'

RSpec.describe 'API V1 Rewards', type: :request, swagger_doc: 'v1/swagger.yaml' do
  path '/api/v1/rewards' do
    get 'Lists rewards' do
      tags 'Rewards'
      produces 'application/json'
      description 'Retrieves all rewards'
      security [{ bearerAuth: [] }]

      response '200', 'Rewards retrieved' do
        run_test!
      end
    end

    post 'Creates a reward' do
      tags 'Rewards'
      consumes 'application/json'
      produces 'application/json'
      description 'Creates a new reward (Admin only)'
      parameter name: :reward, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          description: { type: :string },
          points_cost: { type: :integer }
        },
        required: %w[title points_cost]
      }
      security [{ bearerAuth: [] }]

      response '201', 'Reward created' do
        run_test!
      end

      response '422', 'Unprocessable entity' do
        run_test!
      end
    end
  end

  path '/api/v1/rewards/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'Reward ID'

    patch 'Updates a reward' do
      tags 'Rewards'
      consumes 'application/json'
      produces 'application/json'
      description 'Updates an existing reward (Admin only)'
      parameter name: :reward, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          description: { type: :string },
          points_cost: { type: :integer }
        }
      }
      security [{ bearerAuth: [] }]

      response '200', 'Reward updated' do
        run_test!
      end

      response '422', 'Unprocessable entity' do
        run_test!
      end
    end

    delete 'Deletes a reward' do
      tags 'Rewards'
      produces 'application/json'
      description 'Deletes a reward (Admin only)'
      security [{ bearerAuth: [] }]

      response '204', 'Reward deleted' do
        run_test!
      end

      response '404', 'Reward not found' do
        run_test!
      end
    end
  end
end
