class Department < ApplicationRecord
  enum :level, {
    company: 0,
    board: 1,
    management: 2,
    coordination: 3,
    area: 4
  }

  has_many :sub_departments, class_name: 'Department', foreign_key: 'parent_id'
  belongs_to :parent, class_name: 'Department', optional: true
  has_many :department_users, class_name: 'User', foreign_key: 'department_id'
  # TODO
end
