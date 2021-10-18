class RemoveIndexFromShortUrls < ActiveRecord::Migration[6.0]
  def change
    remove_index :short_urls, :full_url
  end
end
