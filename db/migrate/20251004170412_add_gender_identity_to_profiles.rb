class AddGenderIdentityToProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :profiles, :gender_identity, :string
  end
end
