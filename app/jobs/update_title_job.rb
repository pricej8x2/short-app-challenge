require 'open-uri'

# The UpdateTitleJob job is enqueued upon the creation of a ShortUrl object which has a null title
# attribute when initially created. The purpose of the job is to extract a title from a web page in the background,
# assign the extracted title to the ShortUrl object's title attribute, and save the updated ShortUrl object.
class UpdateTitleJob < ApplicationJob
  queue_as :default

  discard_on StandardError

  # Extracts the title from a web page and update the ShortUrl's title attribute.
  #
  # short_url_id - The Integer ID of the ShortUrl.
  def perform(short_url_id)
    short_url = ShortUrl.find_by!(id: short_url_id)

    begin
      tempfile = URI.open(short_url.full_url)
      document = Nokogiri::HTML.parse(tempfile)
      title = document.title || ''
      short_url.update!(title: title)
    ensure
      # URI.open returns a Tempfile or StringIO object depending on the
      # size of the web page. If a Tempfile object is generated, then
      # it is a good practice to clean up temporary files in an ensure block.
      if tempfile.is_a?(Tempfile)
        tempfile.close
        tempfile.unlink
      end
    end
  end
end
