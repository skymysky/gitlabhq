# frozen_string_literal: true

class ScheduleDropInvalidVulnerabilities < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  MIGRATION = 'DropInvalidVulnerabilities'
  DELAY_INTERVAL = 2.minutes.to_i
  BATCH_SIZE = 10_000

  disable_ddl_transaction!

  def up
    say "Scheduling #{MIGRATION} jobs"
    queue_background_migration_jobs_by_range_at_intervals(
      define_batchable_model('vulnerabilities'),
      MIGRATION,
      DELAY_INTERVAL,
      batch_size: BATCH_SIZE
    )
  end

  def down
    # no-op
  end
end
