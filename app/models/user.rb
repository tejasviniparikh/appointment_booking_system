class User < ApplicationRecord
  rolify
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :availabilities, foreign_key: 'doctor_id'

  has_many :visits, class_name: 'Appointment', foreign_key: 'doctor_id'
  has_many :check_ups, class_name: 'Appointment', foreign_key: 'patient_id'

  validates :first_name, :last_name, presence: true, length: { minimum: 1, maximum: 50 }, format: { with: /\A[^0-9`!@#\$%\^&*+_=]+\z/ }
  validates :mobile_no, presence: true, length: { is: 10 }, format: { with: /[0-9]/ }
  validates :email, presence: { case_sensitive: false }, format: { with: /\A[\w+\-.]+@[\w\d\-.]+\.[A-z]+\z/ }

  def full_name
    return nil if first_name.blank? || last_name.blank?

    "#{first_name} #{last_name}"
  end
end
