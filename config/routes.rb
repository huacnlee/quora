Quora::Application.routes.draw do
  root :to => "home#index"

  match "/uploads/*path" => "gridfs#serve"
  match "/update_in_place" => "home#update_in_place"
  match "/muted" => "home#muted"
  match "/followed" => "home#followed"
  match "/about" => "home#about"

  # devise_for :users, :path => '', :path_names => {:sign_in => "login", :sign_out => "logout", :sign_up => "register", :registration }
  devise_for :users,  :controllers => { :registrations => "registrations" } do
    get "/register", :to => "registrations#new" 
    get "/login", :to => "devise/sessions#new" 
    get "/logout", :to => "devise/sessions#destroy" 
  end
  resources :users do
    member do
      get "answered"
      get "asked"
    end
  end
  match "auth/:provider/callback", :to => "users#auth_callback"  

  
  resources :asks do
    collection do
      get "search"
    end
    member do
      get "spam"
      get "follow"
      get "unfollow"
      get "mute"
      get "unmute"
      post "answer"
      post "update_topic"
      get "update_topic"
    end
  end
  resources :answers do
    member do
      get "vote"
    end
  end
  resources :comments 
  resources :topics

  namespace :cpanel do
    root :to =>  "home#index"
    resources :users
    resources :asks
    resources :answers
    resources :topics
  end
end
