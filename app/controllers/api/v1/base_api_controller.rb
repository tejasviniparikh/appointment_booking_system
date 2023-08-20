# frozen_string_literal: true

module Api
  module V1
    # Base controller for the common methods.
    class BaseApiController < ApplicationController
      include Pundit::Authorization
      include ApiResponder
      before_action :authenticate_user!

      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
      rescue_from ActiveRecord::RecordNotFound, Pundit::NotDefinedError, with: :record_not_found

      def user_not_authorized
        render json: error_json(I18n.t('authorization.unauthorize')), status: 401
      end

      def record_not_found
        render json: error_json(I18n.t('authorization.record_not_found')), status: 404
      end
    end
  end
end
