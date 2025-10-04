class CreateProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :profiles do |t|
      t.string :name
      t.integer :age
      t.text :description
      t.integer :user_id
      t.boolean :active

      t.timestamps
    end
    add_index :profiles, :user_id
  end
end
