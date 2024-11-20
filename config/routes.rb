Rails.application.routes.draw do
  root to: 'qrcodes#index'
  resources :qrcodes, only: [:create, :show], param: :token
end
