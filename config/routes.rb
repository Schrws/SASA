Rails.application.routes.draw do
  root 'home#index'

  get '/files' => 'files#index'
  get '/files/download' => 'files#download'
  get '/files/work' => 'files#work'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
