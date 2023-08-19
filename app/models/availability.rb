class Availability < ApplicationRecord
  belongs_to :doctor, class_name: 'User'
end
