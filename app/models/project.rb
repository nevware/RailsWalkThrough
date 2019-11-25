class Project < ApplicationRecord
  belongs_to :client
  has_many :assignments, dependent: :restrict_with_exception
end
