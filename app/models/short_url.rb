# The ShortUrl model.
class ShortUrl < ApplicationRecord
  CHARACTERS = [*'0'..'9', *'a'..'z', *'A'..'Z'].freeze
  BASE = CHARACTERS.length

  validates :full_url, presence: true
  validates :full_url, length: { maximum: 2048 }, on: :create
  validate :validate_full_url, on: :create
  after_create { UpdateTitleJob.perform_later(id) }

  # Decodes a String short code in base62 to an Integer in base10.
  #
  # str - A String short code in base62.
  #
  # Returns an Integer in base10.
  def self.decode_short_code_to_num(str)
    num = 0
    str.each_char { |char| num = num * BASE + CHARACTERS.index(char) }
    num
  end

  # Encodes an Integer in base10 to a String short code in base62.
  # NOTE: Tables in MariaDB can not be re-configured to start at a value
  # below 1. Therefore, it is unnecessary for this method to return the
  # String '0' when num is equal to the Integer 0.
  #
  # num - An Integer in base10.
  #
  # Returns a String short code in base62.
  def encode_num_to_short_code(num)
    string = ''
    while num.positive?
      string << CHARACTERS[num.modulo(BASE)]
      num /= BASE
    end
    string.reverse
  end

  # Decodes the passed short code into an Integer ID, queries for a ShortUrl object by the generated ID, and
  # returns a ShortUrl object if it exists.
  #
  # short_code - A String short code to decode.
  #
  # Returns a ShortUrl object.
  def self.find_by_short_code(short_code)
    id = decode_short_code_to_num(short_code)
    find_by!(id: id)
  end

  # Generates a String short code from an Integer ID.
  #
  # Returns a String short code or nil if the ID is blank.
  def short_code
    return if id.blank?

    encode_num_to_short_code(id)
  end

  # Updates the title attribute of a ShortUrl object.
  #
  # Returns a String title or nil if the ID is blank.
  def update_title!
    return if id.blank?

    reload.title
  end

  # Validates the short code contains only valid characters from
  # the set of base62 characters.
  #
  # short_code - The String short code.
  #
  # Returns nil if valid.
  def self.validate_short_code(short_code)
    return if short_code.count("^#{CHARACTERS.join}").zero?

    message = "The short code '#{short_code}' is not valid."
    raise ShortenerServiceError::BadRequest::InvalidShortCode, message
  end

  private

  # Validates that the full URL is parseable, uses the HTTP or HTTPs protocol, and
  # a hostname is present.
  def validate_full_url
    uri = URI.parse(full_url)
  rescue URI::Error
    errors.add(:full_url, 'is not a valid url')
  ensure
    if uri.present?
      errors.add(:full_url, 'must be HTTP or HTTPS') unless uri.is_a?(URI::HTTP)
      errors.add(:full_url, 'is missing hostname') if uri.host.nil?
    end
  end
end
