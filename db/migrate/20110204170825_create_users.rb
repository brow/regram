class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :instagram_id
      t.string :instagram_access_token
      t.string :tumblr_access_token
      t.string :tumblr_access_token_secret
      t.string :tumblr_blog_name
      t.string :twitter_access_token
      t.string :twitter_access_token_secret
      t.string :twitter_name

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
