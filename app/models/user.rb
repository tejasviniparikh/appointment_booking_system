class User < ApplicationRecord
  rolify
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable, :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :availabilities

  has_many :visits, class_name: 'Appointment', foreign_key: 'doctor_id'
  has_many :check_ups, class_name: 'Appointment', foreign_key: 'patient_id'
end
