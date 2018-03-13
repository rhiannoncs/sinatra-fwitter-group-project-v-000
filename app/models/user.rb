class User < ActiveRecord::Base
  has_secure_password
  validates_presence_of :username
  validates_presence_of :email
  has_many :tweets
  
  def slug
    self.username.downcase.gsub(/\s/, '-')
  end
  
  def self.find_by_slug(slug)
    all.find{|user| user.slug == slug}
  end
end