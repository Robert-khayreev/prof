class AddHeightAndIncomeLevelToProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :profiles, :height, :integer
    add_column :profiles, :income_level, :string
  end
end
