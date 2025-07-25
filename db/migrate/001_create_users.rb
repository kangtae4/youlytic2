class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.string :first_name
      t.string :last_name
      t.integer :subscription_tier, default: 0
      t.integer :daily_api_quota, default: 3
      t.integer :api_requests_count, default: 0
      t.date :last_quota_reset
      t.boolean :admin, default: false

      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at

      t.timestamps null: false
    end
    
    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
  end
end