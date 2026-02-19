Rails.application.routes.draw do
  resource :session
  resource :registration, only: [:new, :create]
  resources :passwords, param: :token
  
  get "dashboard", to: "dashboard#show"
  
  resources :reviews, only: [:index, :show] do
    member do
      post :generate_reply
      get :manual_post
    end
  end
  
  resources :reply_drafts, only: [:update] do
    member do
      post :approve
      post :send_reply
    end
  end
  
  resources :locations do
    member do
      post :sync_reviews
    end
  end

  # Google OAuth
  get "auth/google", to: "google_oauth#connect", as: :google_oauth_connect
  get "auth/google/callback", to: "google_oauth#callback", as: :google_oauth_callback
  delete "auth/google/:location_id", to: "google_oauth#disconnect", as: :google_oauth_disconnect

  resources :review_imports, only: [:new, :create]
  
  resources :campaigns do
    member do
      get :qr_code
    end
    resources :campaign_responses, only: [:show], path: "responses"
  end
  
  # Public campaign feedback page
  get "c/:slug", to: "public_campaigns#show", as: :public_campaign
  post "c/:slug/respond", to: "public_campaigns#respond", as: :public_campaign_respond
  post "c/:slug/track_click", to: "public_campaigns#track_click", as: :public_campaign_track_click
  
  get "analytics", to: "analytics#show"
  resource :settings, only: [:show, :update]

  # Billing routes
  namespace :billing do
    get "/", to: "overview#show", as: :overview
    resources :plans, only: [:index]
    resources :invoices, only: [:index, :show] do
      resources :payment_proofs, only: [:create]
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  get "privacy", to: "pages#privacy"
  get "terms", to: "pages#terms"
  get "about", to: "pages#about"
  get "contact", to: "pages#contact"

  root "pages#home"
end
