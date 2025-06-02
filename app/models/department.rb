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

  scope :by_level, ->(level) { where(level: level) if level.present? }

  before_save :set_company_id
  before_destroy :destroy_sub_departments
  before_destroy :nullify_users

  def root_department
    return self if company?

    parent&.root_department
  end

  def sub_departments_ids
    sub_departments.flat_map { |d| [d.id] + d.sub_departments_ids }
  end

  private

  def destroy_sub_departments
    sub_departments.each(&:destroy)
  end

  def nullify_users
    department_users.update_all(department_id: nil)
  end

  def set_company_id
    self.company_id = if level == Department.levels['company']
                        id
                      else
                        parent&.root_department&.id
                      end
  end
end
