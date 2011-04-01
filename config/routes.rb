Quora::Application.routes.draw do
  root :to => "home#index"

  match "/uploads/*path" => "gridfs#serve"
  match "/update_in_place" => "home#update_in_place"
  match "/muted" => "home#muted"

  # devise_for :users, :path => '', :path_names => {:sign_in => "login", :sign_out => "logout", :sign_up => "register", :registration }
  devise_for :users,  :controllers => { :registrations => "registrations" } do
    get "/register", :to => "registrations#new" 
    get "/login", :to => "devise/sessions#new" 
    get "/logout", :to => "devise/sessions#destroy" 
  end
  resources :users, :only => :show
  match "auth/:provider/callback", :to => "users#auth_callback"  

  
  resources :asks do
    member do
      get "spam"
      get "follow"
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
end
