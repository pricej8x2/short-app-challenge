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
