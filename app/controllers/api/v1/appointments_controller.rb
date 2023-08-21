# frozen_string_literal: true

module Api
  module V1
    # Appointment controller
    class AppointmentsController < BaseApiController
      def index
        resources = policy_scope(Appointment)
        if resources.present?
          resources =
            if Constants::VALID_APPOINTMENT_STATUSES.include?(params[:status]&.downcase)
              resources.where(status: params[:status])
            else
              resources.scheduled
            end
            if resources.blank?
              render_error(I18n.t('controller_msgs.common.no_data_available'), 200)
              return
            end
          authorize(resources)
          render_success({ data: serialized_json(resources, AppointmentSerializer) })
        else
          render_error(I18n.t('controller_msgs.common.no_data_available'), 200)
        end
      end

      def create
        resource = Appointment.new(resource_params)
        authorize(resource)
        if resource.save
          render_success({ data: serialized_json(resource, AppointmentSerializer) },
                         I18n.t('controller_msgs.appointment.status_updated', status: 'scheduled'), 201)
        else
          render_error(resource)
        end
      end

      def resource_params
        params.require(:appointment).permit(%i[patient_id availability_id])
      end
    end
  end
end
