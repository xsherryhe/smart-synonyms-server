Rails.application.routes.draw do
  get 'init', to: 'application#init'
  get 'words/:word', to: 'words#show'
  get 'synsets/:pos/:pos_offset', to: 'synsets#show'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
