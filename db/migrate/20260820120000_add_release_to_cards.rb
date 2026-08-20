class AddReleaseToCards < ActiveRecord::Migration[8.2]
  def change
    add_column :cards, :release, :string
    add_index :cards, [ :account_id, :release ]
  end
end
