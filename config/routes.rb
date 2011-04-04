Quora::Application.routes.draw do
  root :to => "home#index"

  match "/uploads/*path" => "gridfs#serve"
  match "/update_in_place" => "home#update_in_place"
  match "/muted" => "home#muted"
  match "/newbie" => "home#newbie"
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
      get "follow"
      get "unfollow"
      get "followers"
      get "following"
      get "following_topics"
      get "following_asks"
    end
  end
  match "auth/:provider/callback", :to => "users#auth_callback"  

  resources :search do
    collection do
      get "topics"
    end
  end
  
  resources :asks do
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
  resources :topics do
    member do
      get "follow"
      get "unfollow"
    end
  end
  resources :logs

  namespace :cpanel do
    root :to =>  "home#index"
    resources :users
    resources :asks
    resources :answers
    resources :topics
    resources :comments
  end
end
