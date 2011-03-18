Quora::Application.routes.draw do
  root :to => "home#index"

  # devise_for :users, :path => '', :path_names => {:sign_in => "login", :sign_out => "logout", :sign_up => "register", :registration }
  resources :users, :only => :show
  devise_for :users do
    get "/register", :to => "devise/registrations#new" 
    get "/login", :to => "devise/sessions#new" 
    get "/logout", :to => "devise/sessions#destroy" 
  end

  
  resources :asks
end
