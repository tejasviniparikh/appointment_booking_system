# frozen_string_literal: true

# serializer for appointment
class AppointmentSerializer
  include JSONAPI::Serializer
  attributes :id, :patient_full_name, :patient_id, :status
  attribute :doctor_and_time_details do |object|
    AvailabilitySerializer.new(object.availability).serializable_hash[:data][:attributes]
  end
end
