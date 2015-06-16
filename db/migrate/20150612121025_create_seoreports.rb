class CreateSeoreports < ActiveRecord::Migration
  def change
    create_table :seoreports do |t|
      t.hstore :title, null: false, default: {}
      t.hstore :meta_description, null: false, default: {}
      t.hstore :relevant_keywords, null: false, default: {}
      t.hstore :robots, null: false, default: {}
      t.hstore :sitemap, null: false, default: {}
      t.hstore :alt_tags, null: false, default: {}
      t.hstore :inline_styles, null: false, default: {}
      t.hstore :favicon_url, null: false, default: {}
      t.hstore :google_analytics, null: false, default: {}

      t.text :keywords
      t.text :deprecated_tags

      t.integer :google_rank
      t.integer :google_index
      t.integer :google_backlinks

      t.references :user

      t.integer :points, default: 0
      t.timestamps
    end
  end
end
