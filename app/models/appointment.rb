class Appointment < ApplicationRecord
  belongs_to :doctor, class_name: 'User'
  belongs_to :patient, class_name: 'User'
  belongs_to :availability

  enum status: { scheduled: 0, cancelled: 1 }

  delegate :full_name, to: :doctor, prefix: true
  delegate :full_name, to: :patient, prefix: true

  after_save :update_doctor_availability
  after_create :send_email_notifications

  before_validation :set_doctor_id

  validates :patient_id, :availability_id, :status, presence: true

  validate :multy_patient_appointment
  validate :patient_overlapping_appointments
  validate :book_single_slot_per_day_for_doctor
  validate :patient_role
  validate :appoitment_timings

  def update_doctor_availability
    # silent update as it is not require user's interaction.
    if scheduled?
      availability.update_column('status', 'occupied')
    elsif cancelled?
      availability.update_column('status', 'available')
    end
  end

  def send_email_notifications
    DoctorMailer.appointment_status_update(id).deliver_later
    PatientMailer.appointment_status_update(id).deliver_later
  end

  def formatted_slot_start_time
    availability.start_time&.strftime('%d-%m-%Y %H:%M')
  end

  def set_doctor_id
    return if availability_id.blank?

    self.doctor_id = availability.doctor_id
  end

  def multy_patient_appointment
    # Ensures that not 2 patient books same time slot.
    existing_appointment = Appointment.where(availability_id:, status: 'scheduled')

    return true if existing_appointment.blank?

    errors.add(:base, 'This time slot is already booked.')
  end

  def patient_overlapping_appointments
    # Ensures that patient do not book multiple doctor's appointment on same time.
    scheduled_checkups = Appointment.where(patient_id:, status: 'scheduled')
    return true if scheduled_checkups.blank?

    overlaps = false
    scheduled_checkups.each do |appointment|
      next if appointment.id == id

      overlaps = availability.overlaps?(appointment.availability)
      break if overlaps == true
    end

    return true unless overlaps

    errors.add(:base, 'Overlapping scheduled appointment.')
  end

  def book_single_slot_per_day_for_doctor
    # Ensures that patients can book only 1 time slot of a day for 1 doctor.
    # He/She can book multiple slots for different doctors.

    scheduling_for_date = availability.start_time

    scheduled_appointments = Appointment.joins(:availability).where(doctor_id:, patient_id:, status: 'scheduled').where('availabilities.start_time between ? and ?', scheduling_for_date.beginning_of_day, scheduling_for_date.end_of_day)
    return true if scheduled_appointments.blank?

    errors.add(:base, 'You already scheduled appointment for this day.')
  end

  def patient_role
    errors.add(:base, 'Patient is invalid.') unless patient.is_patient?
    # No need to check for doctor role as we set it using availability and availability checks for doctor role.
  end

  def appoitment_timings
    # Ensures that appointment gets booked atleast 3 hours ago.
    return true if availability.start_time >= (Time.current + 3.hours)

    errors.add(:base, 'Appointments must be booked prior 3 hours.')
  end
end
