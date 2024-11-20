Rails.application.routes.draw do
  root to: 'qrcodes#new'
  resources :qrcodes, only: [:create, :show], param: :token
end
