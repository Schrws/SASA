Rails.application.routes.draw do
  root 'home#index'

  get '/download' => 'home#download'
  get '/work' => 'work#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
