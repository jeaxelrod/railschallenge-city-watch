Rails.application.routes.draw do
  resources :responders, defaults: { format: 'json' }, param: :name
  resources :emergencies, defaults: { format: 'json' }, param: :code
end
