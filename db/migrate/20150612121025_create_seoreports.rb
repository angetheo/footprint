class CreateSeoreports < ActiveRecord::Migration
  def change
    create_table :seoreports do |t|
      # STRUCTURE
      t.hstore :title,              null: false, default: {}
      t.hstore :meta_description,   null: false, default: {}
      t.hstore :relevant_keywords,  null: false, default: {}
      t.hstore :robots,             null: false, default: {}
      t.hstore :sitemap,            null: false, default: {}
      t.hstore :alt_tags,           null: false, default: {}
      t.hstore :inline_styles,      null: false, default: {}
      t.hstore :favicon_url,        null: false, default: {}
      t.hstore :google_analytics,   null: false, default: {}
      t.hstore :deprecated_tags,    null: false, default: {}
      t.text :keywords
      t.integer :google_rank
      t.integer :google_index
      t.integer :google_backlinks
      # SPEED
      t.decimal :load_time, precision: 4, scale: 1
      t.hstore :total_page_size,    null: false, default: {}
      t.hstore :asset_minification, null: false, default: {}
      t.hstore :asset_compression,  null: false, default: {}
      t.hstore :assets,             null: false, default: {}
      t.hstore :caching,            null: false, default: {}
      # SAFETY
      t.hstore :safe_url,           null: false, default: {}

      t.references :user
      t.integer :points, default: 0
      t.timestamps
    end
  end
end
