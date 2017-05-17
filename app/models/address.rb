class Address < ApplicationRecord
  belongs_to :user
  belongs_to :state
  belongs_to :city
  has_many :orders,
           :foreign_key => :shipping_id
end
