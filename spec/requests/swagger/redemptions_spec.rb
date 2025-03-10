require 'swagger_helper'

RSpec.describe 'API V1 Redemptions', type: :request, swagger_doc: 'v1/swagger.yaml' do
  path '/api/v1/redemptions' do
    get 'Lists redemptions for the current user' do
      tags 'Redemptions'
      produces 'application/json'
      description 'Retrieves redemptions for the current user with optional date filters'
      parameter name: :from_date, in: :query, type: :string, format: :date,
                description: 'Filter redemptions from this date'
      parameter name: :to_date, in: :query, type: :string, format: :date,
                description: 'Filter redemptions up to this date'
      security [{ bearerAuth: [] }]

      response '200', 'Redemptions retrieved' do
        run_test!
      end
    end

    post 'Creates a redemption' do
      tags 'Redemptions'
      consumes 'application/json'
      produces 'application/json'
      description 'Creates a new redemption for the current user'
      parameter name: :redemption, in: :body, schema: {
        type: :object,
        properties: {
          reward_id: { type: :integer }
        },
        required: ['reward_id']
      }
      security [{ bearerAuth: [] }]

      response '201', 'Redemption created' do
        run_test!
      end

      response '422', 'Unprocessable entity' do
        run_test!
      end
    end
  end

  path '/api/v1/redemptions/{id}' do
    delete 'Deletes a redemption' do
      tags 'Redemptions'
      produces 'application/json'
      description 'Deletes a redemption for the current user'
      parameter name: :id, in: :path, type: :integer, description: 'Redemption ID'
      security [{ bearerAuth: [] }]

      response '204', 'Redemption deleted' do
        run_test!
      end

      response '404', 'Redemption not found' do
        run_test!
      end
    end
  end
end
