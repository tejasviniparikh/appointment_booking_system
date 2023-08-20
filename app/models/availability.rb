class Availability < ApplicationRecord
  belongs_to :doctor, class_name: 'User'
  enum status: { available: 0, occupied: 1 }
  delegate :full_name, to: :doctor, prefix: true

  before_validation :set_end_time

  validates :start_time, presence: true, comparison: { greater_than: Time.current.strftime('%d-%m-%Y %H:%M') }
  validates :end_time, presence: true, comparison: { greater_than: :start_time }
  validates :doctor_id, :status, presence: true

  validate :overlap_time_slot
  validate :doctor_role

  def date
    start_time&.strftime('%d-%m-%Y')
  end

  def start_time=(start_time)
    if start_time.blank?
      super(start_time)
    else
      formatted_time = Time.parse(start_time)
      super(formatted_time.beginning_of_minute)
    end
  end

  def set_end_time
    return if start_time.blank?

    self.end_time = (start_time + 59.minutes).end_of_minute
  end

  def formatted_start_time
    start_time&.strftime('%H:%M')
  end

  def formatted_end_time
    end_time&.strftime('%H:%M')
  end

  def overlap_time_slot
    overlaps = false

    doctor.availabilities.each do |availability|
      next if availability.id == id

      overlaps = overlaps?(availability)
      break if overlaps == true
    end
    return true unless overlaps

    errors.add(:base, 'Overlapping existing availability.')
  end

  def overlaps?(existing_availability)
    existing_start_time = existing_availability.start_time
    existing_end_time = existing_availability.end_time

    # in range can not happen as we have each slot of 1 hour.
    if end_time_overlaps?(existing_start_time, existing_end_time) || start_time_overlaps?(existing_start_time, existing_end_time)
      true
    else
      false
    end
  end

  def end_time_overlaps?(existing_start_time, existing_end_time)
    end_time >= existing_start_time && end_time <= existing_end_time
  end

  def start_time_overlaps?(existing_start_time, existing_end_time)
    start_time >= existing_start_time && start_time <= existing_end_time
  end

  def doctor_role
    errors.add(:base, 'Doctor is invalid.') unless doctor.is_doctor?
  end

  def check_occupancy
    # Do not allow doctor to update timings if status is occupied
    # pending
  end
end
