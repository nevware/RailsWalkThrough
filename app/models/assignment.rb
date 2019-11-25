class Assignment < ApplicationRecord
  belongs_to :person
  belongs_to :project
  has_many :timesheets, dependent: :restrict_with_exception
end
