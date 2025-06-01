class CreateDepartments < ActiveRecord::Migration[8.0]
  def change
    create_table :departments do |t|
      t.string :name
      t.integer :level, index: true
      t.references :parent, null: true, foreign_key: { to_table: :departments }, index: true
      t.bigint :company_id, index: true
      t.timestamps
    end

    add_foreign_key :departments, :departments, column: :company_id
  end
end
