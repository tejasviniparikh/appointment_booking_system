# frozen_string_literal: true

# availability policy
class AvailabilityPolicy < ApplicationPolicy
  def index?
    if user.is_patient?
      true
    elsif user.is_doctor?
      record.pluck(:doctor_id).all?(user.id)
    end
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
