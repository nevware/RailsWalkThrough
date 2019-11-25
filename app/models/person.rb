class Person < ApplicationRecord
  has_many :assignments, dependent: :restrict_with_exception
end
