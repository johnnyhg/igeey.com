class Comment < ActiveRecord::Base
  belongs_to :user,:counter_cache => true
  belongs_to :commentable, :polymorphic => true,:counter_cache => true  
  validates :content,:length => {:within => 1..1000}
end
