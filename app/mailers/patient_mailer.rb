class PatientMailer < ApplicationMailer
  def appointment_status_update(appointment_id)
    @appointment = Appointment.find_by(id: appointment_id)

    mail(to: @appointment.patient.email, subject: "Appointment #{@appointment.status}")
  end
end
