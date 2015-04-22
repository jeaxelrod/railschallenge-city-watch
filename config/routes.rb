Rails.application.routes.draw do
  resources :responders, defaults: { format: 'json' }, param: :name
end
