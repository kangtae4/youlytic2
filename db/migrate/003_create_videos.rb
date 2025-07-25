class CreateVideos < ActiveRecord::Migration[7.0]
  def change
    create_table :videos do |t|
      t.references :channel, null: false, foreign_key: true
      t.string :youtube_id, null: false
      t.string :title
      t.text :description
      t.string :thumbnail_url
      t.datetime :published_at
      t.string :category_id
      t.string :default_language
      t.integer :duration_seconds
      
      # Statistics
      t.jsonb :statistics, default: {}
      t.jsonb :metadata, default: {}
      
      # Cached computed values
      t.bigint :view_count, default: 0
      t.bigint :like_count, default: 0
      t.bigint :comment_count, default: 0
      
      # Analysis data
      t.decimal :engagement_rate, precision: 5, scale: 4
      t.decimal :estimated_revenue_min, precision: 10, scale: 2
      t.decimal :estimated_revenue_max, precision: 10, scale: 2
      
      t.timestamps
    end
    
    add_index :videos, :youtube_id, unique: true
    add_index :videos, [:channel_id, :published_at]
    add_index :videos, :view_count
    add_index :videos, :engagement_rate
  end
end