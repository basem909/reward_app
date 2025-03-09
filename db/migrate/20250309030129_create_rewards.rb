class CreateRewards < ActiveRecord::Migration[7.1]
  def change
    create_table :rewards do |t|
      t.string :title
      t.text :description
      t.integer :points_cost

      t.timestamps
    end
  end
end
