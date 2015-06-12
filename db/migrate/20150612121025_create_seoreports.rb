class CreateSeoreports < ActiveRecord::Migration
  def change
    create_table :seoreports do |t|
      t.text :title
      t.text :meta_description
      t.text :body
      t.references :user

      t.integer :points, default: 0
      t.timestamps
    end
  end
end
