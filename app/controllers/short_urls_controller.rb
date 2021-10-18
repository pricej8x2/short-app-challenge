# The ShortUrlsController class.
class ShortUrlsController < ApplicationController
  # Since we're working on an API, we don't have authenticity tokens
  skip_before_action :verify_authenticity_token

  # Returns a JSON object that contains the top 100 most frequently accessed short codes.
  def index
    short_codes = ShortUrl.select(:id).order(click_count: :desc).limit(100).map(&:short_code)
    return_response({ urls: short_codes }, :ok)
  end

  # Creates a ShortUrl object from a full URL.
  #
  # Returns a JSON object containing the short code of the ShortUrl object that got created.
  def create
    short_url = ShortUrl.create!(short_url_params)
    return_response({ short_code: short_url.short_code }, :created)
  end

  def show
  end

  private

  # Checks to see if the full_url parameter exists and has a value. If it does, then an
  # ActionController::Parameters instance is returned with the permitted flag set to true.
  #
  # Returns an ActionController::Parameters instance.
  def short_url_params
    params.require(:full_url)
    params.permit(:full_url)
  end
end
