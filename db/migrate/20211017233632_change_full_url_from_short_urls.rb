class ChangeFullUrlFromShortUrls < ActiveRecord::Migration[6.0]
  def up
    change_column :short_urls, :full_url, :string, limit: 2048, null: false
  end

  def down
    change_column :short_urls, :full_url, :string
  end
end
