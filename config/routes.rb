Rails.application.routes.draw do
  devise_for :users

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
