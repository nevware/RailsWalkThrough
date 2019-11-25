class Client < ApplicationRecord
  has_many :projects, dependent: :restrict_with_exception
end
