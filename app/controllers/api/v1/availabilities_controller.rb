# frozen_string_literal: true

module Api
  module V1
    # Availabiliy controller
    class AvailabilitiesController < BaseApiController
      include DateFormatValidator

      before_action :validate_date_format, only: %i[create update]

      def index
        resources = policy_scope(Availability)
        if resources.present?
          authorize(resources)
          render_success({ data: serialized_json(resources, AvailabilitySerializer) })
        else
          render_error(I18n.t('controller_msgs.common.no_data_available'), 200)
        end
      end

      def create
        resource = Availability.new(resource_params)
        authorize(resource)
        if resource.save
          render_success({ data: serialized_json(resource, AvailabilitySerializer) },
                         I18n.t('controller_msgs.common.created', resource: 'Availability'), 201)
        else
          render_error(resource)
        end
      end

      def update
        resource = Availability.find_by(id: params[:id])
        authorize(resource)
        if resource.update(resource_params)
          render_success({ data: serialized_json(resource, AvailabilitySerializer) },
                         I18n.t('controller_msgs.common.updated', resource: 'Availability'))
        else
          render_error(resource)
        end
      end

      def resource_params
        params.require(:availability).permit(%i[doctor_id start_time])
      end

      def validate_date_format
        return if valid_date?(params[:availability][:start_time])

        render_error('Start time is missing or have invalid date format')
      end
    end
  end
end
