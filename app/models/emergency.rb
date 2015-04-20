class Emergency < ActiveRecord::Base
  validates :code,             uniqueness: true
  validates :fire_severity,    presence: true, greater_than_zero: true
  validates :police_severity,  presence: true, greater_than_zero: true
  validates :medical_severity, presence: true, greater_than_zero: true
end
