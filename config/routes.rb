Nonomura::Application.routes.draw do
  resources :translations, only: %w(create)
  get "translations", to: "translations#create"
  root :to => 'translations#new'
end
