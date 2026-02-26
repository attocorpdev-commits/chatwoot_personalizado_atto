class AddFollowUpSentAtToConversations < ActiveRecord::Migration[7.1]
  def change
    add_column :conversations, :follow_up_sent_at, :datetime
    add_index :conversations, :follow_up_sent_at
  end
end
