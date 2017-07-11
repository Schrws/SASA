class CreateUpdates < ActiveRecord::Migration[5.0]
  def change
    create_table :updates do |t|
      t.datetime :updated_at

      t.timestamps
    end
  end
end
