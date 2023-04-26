Rails.application.routes.draw do
  mount Datastore::Root => '/'

  root to: proc { [200, {}, ['']] }

  get :ping, to: 'status#ping'
  get :health, to: 'status#health'

  # catch-all route
  match '*path', to: 'errors#not_found', via: :all, constraints:
    lambda { |_request| !Rails.application.config.consider_all_requests_local }
end
