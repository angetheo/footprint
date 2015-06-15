class CreateSeoreports < ActiveRecord::Migration
  def change
    create_table :seoreports do |t|
      t.text :title
      t.text :meta_description
      t.text :body
      t.boolean :robots
      t.boolean :sitemap
      t.decimal :alt_tags, scale: 2, precision: 3
      t.integer :inline_style
      t.string :favicon_url
      t.text :deprecated_tags

      t.boolean :google_analytics
      t.integer :google_rank
      t.integer :google_index

      t.references :user

      t.integer :points, default: 0
      t.timestamps
    end
  end
end
