class User < ApplicationRecord
  include Roles

  has_secure_password

  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :role, presence: true, inclusion: { in: Roles::ROLES }
end
