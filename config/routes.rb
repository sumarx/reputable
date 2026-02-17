Rails.application.routes.draw do
  resource :session
  resource :registration, only: [:new, :create]
  resources :passwords, param: :token
  
  get "dashboard", to: "dashboard#show"
  
  resources :reviews, only: [:index, :show] do
    member do
      post :generate_reply
    end
  end
  
  resources :reply_drafts, only: [:update] do
    member do
      post :approve
      post :send_reply
    end
  end
  
  resources :locations
  
  resources :campaigns do
    member do
      get :qr_code
    end
  end
  
  # Public campaign feedback page
  get "c/:slug", to: "public_campaigns#show", as: :public_campaign
  post "c/:slug/respond", to: "public_campaigns#respond", as: :public_campaign_respond
  
  get "analytics", to: "analytics#show"
  resource :settings, only: [:show, :update]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "dashboard#show"
end
