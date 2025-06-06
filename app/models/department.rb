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

  scope :by_level, ->(level) { where(level: level) if level.present? }

  validate :parent_presence_and_level_consistency
  validate :immutable_attributes_on_update, on: :update

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
    all_department_ids = [id] + sub_departments_ids
    User.where(department_id: all_department_ids).update_all(department_id: nil)
  end

  def set_company_id
    self.company_id = if level == Department.levels['company']
                        id
                      else
                        parent&.root_department&.id
                      end
  end

  def parent_presence_and_level_consistency
    if company?
      errors.add(:parent_id, 'must be blank for company-level departments') if parent_id.present?
    elsif parent.blank?
      errors.add(:parent_id, 'must be present for non-company departments')
    elsif Department.levels[parent.level] >= Department.levels[level]
      errors.add(:parent_id, 'must be of higher level than the current department')
    end
  end

  def immutable_attributes_on_update
    immutable_fields = %w[level parent_id company_id]

    immutable_fields.each do |field|
      errors.add(field.to_sym, 'cannot be changed after creation') if send("#{field}_changed?")
    end
  end
end
