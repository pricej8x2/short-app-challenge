# The ApplicationController class.
class ApplicationController < ActionController::Base
  rescue_from StandardError do |error|
    case error
    when ActiveRecord::RecordNotFound
      status = :not_found
    when ActionController::ParameterMissing, ActiveRecord::ActiveRecordError
      status = :bad_request
    when ShortenerServiceError
      status = error.status
    when StandardError
      status = :internal_server_error
    end

    return_error_response(error, status)
  end

  # Sends an error response.
  #
  # error -  The error instance.
  # status - The Symbol representing the HTTP status code to send with the response.
  def return_error_response(error, status)
    Rails.logger.error error
    render json: { status: status, message: error.message }, status: status
  end
end
