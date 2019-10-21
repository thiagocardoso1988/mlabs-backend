Rails.application.routes.draw do
  # resources :parks, :path => "parking"
  scope '/parking' do
    get '/', to: "parks#index"
    get '/:plate', to: "parks#show"
    post '/', to: "parks#create"
    put '/:id/pay', to: "parks#pay"
    put '/:id/out', to: "parks#out"
  end
end