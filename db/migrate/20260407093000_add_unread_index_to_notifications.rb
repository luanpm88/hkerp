class AddUnreadIndexToNotifications < ActiveRecord::Migration
  disable_ddl_transaction!

  INDEX_NAME = "idx_notifications_unread_user_created_at".freeze

  def up
    return if index_name_exists?(:notifications, INDEX_NAME, false)

    execute <<-SQL
      CREATE INDEX CONCURRENTLY #{INDEX_NAME}
      ON notifications (user_id, created_at DESC)
      WHERE viewed = 0
    SQL
  end

  def down
    return unless index_name_exists?(:notifications, INDEX_NAME, false)

    execute "DROP INDEX CONCURRENTLY #{INDEX_NAME}"
  end
end
