Rails.application.routes.draw do
  mount Datastore::Root => '/'

  get :ping, to: 'status#ping'

  # catch-all route
  match '*path', to: 'errors#not_found', via: :all, constraints:
    lambda { |_request| !Rails.application.config.consider_all_requests_local }
end
