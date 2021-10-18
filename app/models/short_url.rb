class ShortUrl < ApplicationRecord
  CHARACTERS = [*'0'..'9', *'a'..'z', *'A'..'Z'].freeze
  BASE = CHARACTERS.length

  validates :full_url, presence: true
  validates :full_url, length: { maximum: 2048 }, on: :create
  validate :validate_full_url, on: :create
  after_create { UpdateTitleJob.perform_later(id) }

  # Encodes an Integer in base10 to a String short code in base62.
  #
  # num - An Integer in base10.
  #
  # Returns a String short code in base62.
  def self.encode_num_to_short_code(num)
    return '0' if num.zero?

    string = ''
    while num.positive?
      string << CHARACTERS[num.modulo(BASE)]
      num /= BASE
    end
    string.reverse
  end

  # Generates a String short code from an Integer ID.
  #
  # Returns a String short code or nil if the ID is blank.
  def short_code
    return if id.blank?

    ShortUrl.encode_num_to_short_code(id)
  end

  def update_title!
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
