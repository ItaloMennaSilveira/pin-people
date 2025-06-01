class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email, index: true
      t.string :company_email
      t.string :position
      t.string :function
      t.string :city
      t.integer :company_tenure
      t.integer :genre
      t.integer :generation
      t.references :department, null: false, foreign_key: true, index: true

      t.timestamps
    end

    add_index :users, :company_email, unique: true
  end
end


