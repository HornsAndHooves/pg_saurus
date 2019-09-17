class User < ActiveRecord::Base
  has_one :citizen, class_name: 'Demography::Citizen'
end
