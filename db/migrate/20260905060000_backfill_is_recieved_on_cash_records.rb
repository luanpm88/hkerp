class BackfillIsRecievedOnCashRecords < ActiveRecord::Migration
  # `payment_records.is_recieved` has been unreliable since the custom
  # pay/receive form was written: the form posted a top-level `is_recieved`
  # parameter while strong parameters only permitted it nested under
  # `payment_record[...]`, so the value never reached the model and every row
  # kept the column default of false.
  #
  # Direction was therefore carried solely by the sign of `amount`
  # (negative = pay, positive = receive), which is what PaymentRecord#is_paid
  # and every report already use. On production this left 1,091 of the 1,096
  # receive rows flagged `is_recieved = false`.
  #
  # PaymentRecord#normalise_cash_direction now keeps the column in sync on
  # every save. This migration repairs the existing rows so the column agrees
  # with the sign everywhere.
  #
  # Nothing reads `is_recieved` today, so this only makes the data honest — it
  # does not change any figure in the cash book, account book or statistics.
  # Re-running it is a no-op.

  def up
    say_with_time 'Backfilling payment_records.is_recieved from amount sign' do
      execute <<-SQL
        UPDATE payment_records
        SET    is_recieved = (amount >= 0)
        WHERE  type_name = 'custom'
          AND  is_recieved IS DISTINCT FROM (amount >= 0)
      SQL
    end
  end

  def down
    # Intentionally irreversible: the previous values were wrong, and there is
    # no record of which of them were wrong-by-default versus wrong-by-accident.
    say 'Not reverting — the previous is_recieved values were incorrect by construction.'
  end
end
