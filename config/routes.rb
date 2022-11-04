Rails.application.routes.draw do
  mount Datastore::V1::Applications => '/'
end
