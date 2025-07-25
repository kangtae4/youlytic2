class CreateChannelSnapshots < ActiveRecord::Migration[7.0]
  def change
    create_table :channel_snapshots do |t|
      t.references :channel, null: false, foreign_key: true
      t.date :snapshot_date, null: false
      
      # Statistics at the time of snapshot
      t.bigint :subscriber_count, default: 0
      t.bigint :video_count, default: 0
      t.bigint :view_count, default: 0
      
      # Additional metrics
      t.jsonb :daily_metrics, default: {}
      t.integer :videos_published_count, default: 0
      t.bigint :daily_views_gained, default: 0
      t.integer :daily_subscribers_gained, default: 0
      
      t.timestamps
    end
    
    add_index :channel_snapshots, [:channel_id, :snapshot_date], unique: true
    add_index :channel_snapshots, :snapshot_date
  end
end