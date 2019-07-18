class Demography::Country < ActiveRecord::Base
  has_many :citizens, class_name: 'Demography::Citizen'
end
