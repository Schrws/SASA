class CreateDocuments < ActiveRecord::Migration[5.0]
  def change
    create_table :documents do |t|
      t.string :name
      t.integer :size
      t.string :location
      t.string :link
      t.datetime :uploaded_at

      t.timestamps
    end
  end
end
