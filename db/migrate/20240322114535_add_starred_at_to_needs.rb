class AddStarredAtToNeeds < ActiveRecord::Migration[7.0]
  def change
    add_column :needs, :starred_at, :datetime, precision: nil
  end
end
