class AddImageIndexToProfileInteractions < ActiveRecord::Migration[8.0]
  def change
    add_column :profile_interactions, :image_index, :integer
  end
end
