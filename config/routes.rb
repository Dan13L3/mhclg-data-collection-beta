Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get "about", to: "about#index"
  get "/", to: "test#index"
  get "form", to: "case_logs#next_question"
  post "form", to: "case_logs#next_question"

  resources :case_logs
end
