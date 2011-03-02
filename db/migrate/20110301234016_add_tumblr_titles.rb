class AddTumblrTitles < ActiveRecord::Migration
  def self.up
    # add_column :users, :tumblr_blog_title, :string
        
    for user in User.find(:all).select{|user| user.tumblr?}
      puts "Updating tumblr #{user.tumblr_blog_name}"
      
      # Convert blog name to *.tumblr.com format
      user.tumblr_blog_name = user.tumblr_blog_name + '.tumblr.com'
  
      # Look up and store the blog's title
      tumblr_blog = user.tumblr_blogs.find do |blog|
        blog[:name] == user.tumblr_blog_name
      end
      user.tumblr_blog_title = tumblr_blog[:title]
      
      user.save
    end
  end

  def self.down
    remove_column :users, :tumblr_blog_title
  end
end
