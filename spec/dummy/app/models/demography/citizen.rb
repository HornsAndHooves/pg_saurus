class Demography::Citizen < ActiveRecord::Base
  belongs_to :user
end
