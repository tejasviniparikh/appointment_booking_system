class Appointment < ApplicationRecord
  belongs_to :doctor, class_name: 'User'
  belongs_to :patient, class_name: 'User'
  belongs_to :availability

  enum status: { scheduled: 0, cancelled: 1 }

  delegate :full_name, to: :doctor, prefix: true
  delegate :full_name, to: :patient, prefix: true

  after_save :update_doctor_availability
  after_create :send_email_notifications

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
end
