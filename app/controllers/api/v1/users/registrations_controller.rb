# frozen_string_literal: true

module Api
  module V1
    module Users
      # Registartions Controller for Sign up
      class RegistrationsController < Devise::RegistrationsController
        include ApiResponder
        include Constants

        respond_to :json

        def create
          if Constants::VALID_ROLES.include?(sign_up_params[:role]&.downcase)
            build_resource(sign_up_params.except(:role))

            return render_error(resource) unless resource.save
            return unless resource.persisted?

            resource.add_role(sign_up_params[:role].downcase)
            if resource.active_for_authentication?
              sign_up(resource_name, resource)

              render_success({ data: serialized_json(resource, UserSerializer) },
                             I18n.t('devise.registrations.signed_up'))
            else
              expire_data_after_sign_in!
              render_error(I18n.t('devise.registrations.sign_up_failed'))
            end
          else
            render_error(I18n.t('devise.registrations.invalid_role_params'), 400)
          end
        end

        protected

        def sign_up_params
          params.require(:user).permit(%i[email first_name last_name password password_confirmation mobile_no role])
        end
      end
    end
  end
end
