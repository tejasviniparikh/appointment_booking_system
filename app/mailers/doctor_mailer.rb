class DoctorMailer < ApplicationMailer
  def appointment_status_update(appointment_id)
    @appointment = Appointment.find_by(id: appointment_id)

    mail(to: @appointment.doctor.email, subject: "Appointment #{@appointment.status}")
  end
end
