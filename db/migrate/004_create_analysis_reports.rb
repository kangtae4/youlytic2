class CreateAnalysisReports < ActiveRecord::Migration[7.0]
  def change
    create_table :analysis_reports do |t|
      t.references :user, null: true, foreign_key: true
      t.references :channel, null: false, foreign_key: true
      
      t.string :status, default: 'pending'
      t.string :permalink_token
      t.datetime :permalink_expires_at
      
      # Report data stored as JSON
      t.jsonb :report_data, default: {}
      t.jsonb :summary_metrics, default: {}
      t.jsonb :revenue_analysis, default: {}
      t.jsonb :content_analysis, default: {}
      
      # Processing info
      t.text :error_message
      t.datetime :started_at
      t.datetime :completed_at
      t.integer :processing_duration_seconds
      
      # Export tracking
      t.integer :pdf_downloads, default: 0
      t.integer :csv_exports, default: 0
      t.integer :shares_count, default: 0
      
      t.timestamps
    end
    
    add_index :analysis_reports, :permalink_token, unique: true
    add_index :analysis_reports, :status
    add_index :analysis_reports, [:user_id, :created_at]
    add_index :analysis_reports, :permalink_expires_at
  end
end