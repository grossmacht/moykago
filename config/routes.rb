Rails.application.routes.draw do
  root "home#index"

  get "moykalar",      to: "washes#index",   as: :washes
  get "moyka/:slug",   to: "washes#show",    as: :wash

  resources :bookings, only: [ :create ]
  get  "bron/:code",        to: "bookings#show",   as: :booking_status
  post "bron/:code/bekor",  to: "bookings#cancel", as: :cancel_booking
  get  "bronlarim",         to: "bookings#lookup", as: :lookup

  resources :reviews, only: [ :create ]

  get    "panel/kirish",  to: "panel/sessions#new",     as: :panel_login
  post   "panel/kirish",  to: "panel/sessions#create"
  delete "panel/chiqish", to: "panel/sessions#destroy", as: :panel_logout

  namespace :panel do
    resources :bookings, only: [ :index, :update ]
    resources :services, only: [ :index, :create, :edit, :update, :destroy ]
    resource  :wash, only: [ :edit, :update ]
  end

  namespace :admin do
    root "dashboard#index"
    resources :washes, except: [ :show ]
    resources :bookings, only: [ :index ]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
