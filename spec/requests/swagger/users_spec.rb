require 'swagger_helper'

RSpec.describe 'API V1 Users', type: :request, swagger_doc: 'v1/swagger.yaml' do
  ### Users Endpoints

  path '/api/v1/users/me/points' do
    get 'Retrieves current user points' do
      tags 'Users'
      produces 'application/json'
      description 'Returns the points balance for the authenticated user'
      security [{ bearerAuth: [] }]

      response '200', 'Points retrieved' do
        schema type: :object,
               properties: {
                 points: { type: :integer }
               },
               required: ['points']
        run_test!
      end

      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end

  path '/api/v1/users/update_user_points' do
    patch 'Updates user points (Admin only)' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      description 'Updates the points for a specific user. Requires admin privileges.'
      parameter name: :points, in: :query, type: :integer, description: 'New points value'
      parameter name: :user_id, in: :query, type: :integer, description: "User's id"
      security [{ bearerAuth: [] }]

      response '200', 'User points updated' do
        schema type: :object,
               properties: {
                 message: { type: :string }
               },
               required: ['message']
        run_test!
      end

      response '422', 'Unprocessable Entity' do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } }
               },
               required: ['errors']
        run_test!
      end

      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end

  ### Authentication Endpoints

  # Sign Up
  path '/users' do
    post 'Registers a new user (sign up)' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      description 'Registers a new user and returns the created user object.'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, example: 'newuser@example.com' },
              password: { type: :string, format: :password, example: 'password' },
              password_confirmation: { type: :string, format: :password, example: 'password' }
            },
            required: %w[email password password_confirmation]
          }
        },
        required: ['user']
      }

      response '201', 'User registered' do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :integer, example: 1 },
                     email: { type: :string, example: 'newuser@example.com' }
                   },
                   required: %w[id email]
                 }
               },
               required: ['data']
        run_test!
      end

      response '422', 'Unprocessable Entity' do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } }
               },
               required: ['errors']
        run_test!
      end
    end
  end

  # Sign In
  path '/users/sign_in' do
    post 'Signs in a user' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      description 'Signs in a user and returns a JWT in the Authorization header.'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, example: 'newuser@example.com' },
              password: { type: :string, format: :password, example: 'password' }
            },
            required: %w[email password]
          }
        },
        required: ['user']
      }

      response '200', 'User signed in' do
        header 'Authorization', schema: {
          type: :string,
          description: 'JWT token'
        }
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :integer, example: 1 },
                     email: { type: :string, example: 'newuser@example.com' }
                   },
                   required: %w[id email]
                 }
               },
               required: ['data']
        run_test!
      end

      response '401', 'Unauthorized' do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } }
               },
               required: ['errors']
        run_test!
      end
    end
  end

  # Sign Out
  path '/users/sign_out' do
    delete 'Signs out a user' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      description 'Signs out a user, revoking the JWT. Requires a valid JWT token.'
      security [{ bearerAuth: [] }]

      response '204', 'User signed out' do
        run_test!
      end

      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end
end
