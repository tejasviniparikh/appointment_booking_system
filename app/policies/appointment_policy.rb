# frozen_string_literal: true

# appointment policy
class AppointmentPolicy < ApplicationPolicy
  def index?
    if user.is_patient?
      record.pluck(:patient_id).all?(user.id)
    elsif user.is_doctor?
      record.pluck(:doctor_id).all?(user.id)
    end
  end

  def create?
    user.is_patient? && record.patient_id == user.id
  end

  # Scope class to define scopes
  class Scope < Scope
    def resolve
      if user.is_doctor?
        scope.where(doctor_id: user.id)
      elsif user.is_patient?
        scope.where(patient_id: user.id)
      end
    end
  end
end
