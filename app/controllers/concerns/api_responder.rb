# frozen_string_literal: true

module ApiResponder
  def success_json(data, message = '')
    data.merge(message:, success: true)
  end

  def success_json_with_params(data, message = '', record_params = {})
    data.merge(message:, success: true).merge!(record_params)
  end

  def error_json(detail)
    {
      errors: errors(detail),
      success: false
    }
  end

  def render_success(data, message = '', status = nil, record_params = {})
    json_data = if record_params.empty?
                  success_json(data, message)
                else
                  success_json_with_params(data,
                                           message, record_params)
                end
    render json: json_data, status: status || 200
  end

  def render_error(data, status = nil)
    render json: error_json(data), status: status || 422
  end

  def serialized_json(details, serializer_class)
    return details if serializer_class.nil?

    records = serializer_class.new(details).serializable_hash[:data]
    records.instance_of?(Hash) ? records[:attributes] : records.map { |record| record[:attributes] }
  end

  private

  def errors(detail)
    return detail if detail.is_a? String

    detail.errors.full_messages.join(', ')
  end
end
