# frozen_string_literal: true

module Api
  module V1
    module Users
      # Sessions Controller for Sign up
      class SessionsController < Devise::SessionsController
        include ApiResponder
        respond_to :json

        before_action :sign_in_params, only: :create
        before_action :load_user, only: :create

        # sign-in
        def create
          if @user.valid_password?(sign_in_params[:password])
            sign_in 'user', @user
            render_success({ data: serialized_json(@user, UserSerializer) }, I18n.t('devise.sessions.signed_in'))
          else
            render_error(I18n.t('devise.sessions.invalid_email_password'))
          end
        end

        # sign-out
        def destroy
          signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
          session.clear
          if signed_out
            render_success({}, I18n.t('devise.sessions.signed_out'))
          else
            render_error(I18n.t('devise.sessions.sign_out_failed'), 401)
          end
        end

        private

        def load_user
          @user = User.find_for_database_authentication(email: sign_in_params[:email])
          return @user unless @user.nil?

          render_error(I18n.t('devise.sessions.invalid_email'), 401)
        end

        def respond_to_on_destroy
          if current_user.present?
            render_success({}, I18n.t('devise.sessions.signed_out'))
          else
            render_error(I18n.t('devise.sessions.already_signed_out'), 401)
          end
        end
      end
    end
  end
end
