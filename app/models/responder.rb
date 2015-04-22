class Responder < ActiveRecord::Base
  self.inheritance_column = nil
  validates :type, no_change: true, presence: true
  validates :capacity, no_change: true, presence: true, inclusion: 1..5
  validates :name, uniqueness: true, presence: true
end
