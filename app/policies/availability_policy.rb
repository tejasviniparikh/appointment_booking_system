# frozen_string_literal: true

# availability policy
class AvailabilityPolicy < ApplicationPolicy
  def index?
    return true if user.is_patient?

    return false unless user.is_doctor?

    doctor_id = record.pluck(:doctor_id).uniq

    return false if doctor_id.count > 1

    doctor_id.first == user.id
  end

  def create?
    user.is_doctor? && record.doctor_id == user.id
  end

  def update?
    user.is_doctor? && record.doctor_id == user.id
  end

  # Scope class to define scopes
  class Scope < Scope
    def resolve
      if user.is_doctor?
        scope.where(doctor_id: user.id)
      elsif user.is_patient?
        scope.available
      end
    end
  end
end
