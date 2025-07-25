class CreateChannels < ActiveRecord::Migration[7.0]
  def change
    create_table :channels do |t|
      t.string :youtube_id, null: false
      t.string :title
      t.text :description
      t.string :thumbnail_url
      t.string :banner_url
      t.string :country
      t.string :default_language
      t.datetime :published_at
      
      # Statistics (stored as JSON for flexibility)
      t.jsonb :statistics, default: {}
      t.jsonb :branding_settings, default: {}
      t.jsonb :metadata, default: {}
      
      # Cached computed values
      t.bigint :subscriber_count, default: 0
      t.bigint :video_count, default: 0
      t.bigint :view_count, default: 0
      
      # Analysis tracking
      t.datetime :last_analyzed_at
      t.integer :analysis_count, default: 0
      
      t.timestamps
    end
    
    add_index :channels, :youtube_id, unique: true
    add_index :channels, :subscriber_count
    add_index :channels, :view_count
    add_index :channels, :last_analyzed_at
  end
end