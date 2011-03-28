Quora::Application.routes.draw do
  root :to => "home#index"
  match "/uploads/*path" => "gridfs#serve"

  # devise_for :users, :path => '', :path_names => {:sign_in => "login", :sign_out => "logout", :sign_up => "register", :registration }
  devise_for :users,  :controllers => { :registrations => "registrations" } do
    get "/register", :to => "registrations#new" 
    get "/login", :to => "devise/sessions#new" 
    get "/logout", :to => "devise/sessions#destroy" 
  end
  resources :users, :only => :show

  
  resources :asks do
    member do
      get "follow"
      get "mute"
      post "answer"
    end
  end
  resources :answers do
    member do
      get "vote"
    end
  end
  resources :comments 
end
