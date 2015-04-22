Rails.application.routes.draw do
  resources :responders, except: :show, defaults: { format: 'json' }
  get '/responders/:name', to: 'responders#show', defaults: { format: 'json' }
end
