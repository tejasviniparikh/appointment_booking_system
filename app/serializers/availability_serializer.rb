# frozen_string_literal: true

# serializer for avilability
class AvailabilitySerializer
  include JSONAPI::Serializer
  attributes :id, :date, :formatted_start_time, :formatted_end_time, :doctor_full_name, :doctor_id
end
