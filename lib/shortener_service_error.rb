# The ShortenerService error base class.
class ShortenerServiceError < StandardError
  attr_reader :message, :status

  # message - The String error message.
  # status  - The Symbol representing the HTTP status code to send
  #           with the response.
  def initialize(message, status)
    @message = message
    @status = status
  end
end

class ShortenerServiceError::BadRequest < ShortenerServiceError
  def initialize(message)
    super(message, :bad_request)
  end
end

class ShortenerServiceError::BadRequest::InvalidShortCode < ShortenerServiceError
  def initialize(message)
    super(message, :bad_request)
  end
end
