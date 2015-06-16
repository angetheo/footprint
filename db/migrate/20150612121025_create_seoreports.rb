class CreateSeoreports < ActiveRecord::Migration
  def change
    create_table :seoreports do |t|
      t.hstore :title, null: false, default: {}
      t.hstore :meta_description, null: false, default: {}
      t.hstore :relevant_keywords, null: false, default: {}

      t.text :keywords
      t.boolean :robots
      t.boolean :sitemap
      t.decimal :alt_tags, scale: 2, precision: 3
      t.integer :inline_style
      t.string :favicon_url
      t.text :deprecated_tags

      t.boolean :google_analytics
      t.integer :google_rank
      t.integer :google_index
      t.integer :google_backlinks

      t.references :user

      t.integer :points, default: 0
      t.timestamps
    end
  end
end
