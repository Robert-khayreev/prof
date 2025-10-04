class CreateProfileInteractions < ActiveRecord::Migration[8.0]
  def change
    create_table :profile_interactions do |t|
      t.integer :profile_id
      t.string :viewer_session
      t.string :action
      t.integer :time_spent
      t.integer :scroll_depth

      t.timestamps
    end
    add_index :profile_interactions, :profile_id
  end
end
