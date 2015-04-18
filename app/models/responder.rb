class Responder < ActiveRecord::Base
  validates :type, no_change: true
  validates :capacity, no_change: true, inclusion: 1..5
  validates :name, uniqueness: true
end
