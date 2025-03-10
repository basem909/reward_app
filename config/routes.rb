Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  devise_for :users, controllers: { registrations: 'users/registrations', sessions: 'users/sessions' }

  namespace :api do
    namespace :v1 do
      resources :rewards
      resources :redemptions, only: [:create, :index, :destroy]
      get 'users/me/points', to: 'users#points'
      patch 'users/update_user_points', to: 'users#update_user_points'
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
