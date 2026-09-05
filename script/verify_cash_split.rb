# Verification for the Cash - Pay / Cash - Receive split.
#
#   bundle exec rails runner script/verify_cash_split.rb
#
# Exercises the model contract that the two screens rely on. Everything it
# creates is destroyed at the end, and it only ever touches records it made
# itself (note prefixed with VERIFY_CASH_SPLIT).
#
# Run it against the Docker development database, never production.

# The container image sets no locale, so Ruby's default external encoding is
# US-ASCII and any non-ASCII character in the output raises on write.
STDOUT.set_encoding('UTF-8')
STDERR.set_encoding('UTF-8')

MARKER = 'VERIFY_CASH_SPLIT'

$failures = []
$checks   = 0

def check(desc, condition)
  $checks += 1
  if condition
    puts "  ok    #{desc}"
  else
    puts "  FAIL  #{desc}"
    $failures << desc
  end
end

def section(title)
  puts ""
  puts title
  puts '-' * title.length
end

method = PaymentMethod.first
user   = User.first

abort 'No PaymentMethod in the database -- seed one first.' if method.nil?
abort 'No User in the database -- seed one first.'           if user.nil?

def build(direction, amount, method, user)
  r = PaymentRecord.new(
    note:           "#{MARKER} #{direction}",
    amount:         amount,
    payment_method: method,
    paid_date:      Date.today,
    type_name:      PaymentRecord::CASH_TYPE
  )
  r.cash_direction_input = direction
  r.accountant = user
  r.save!
  r
end

created = []

begin
  # ---------------------------------------------------------------------------
  section 'Create -- the sign is decided by the screen, not by what was typed'
  # ---------------------------------------------------------------------------

  # The user is on the Cash - Pay screen and types a plain positive number.
  pay = build('pay', 150_000, method, user)
  created << pay
  pay.reload
  check 'pay: amount stored negative',            pay.amount.to_f == -150_000.0
  check 'pay: is_recieved persisted as false',    pay.is_recieved == false
  check 'pay: cash_direction reports pay',        pay.cash_direction == 'pay'
  check 'pay: is_paid true (feeds the cash book)', pay.is_paid == true

  # The user is on the Cash - Receive screen and (wrongly) types a negative.
  rec = build('receive', -250_000, method, user)
  created << rec
  rec.reload
  check 'receive: amount stored positive',         rec.amount.to_f == 250_000.0
  check 'receive: is_recieved persisted as true',  rec.is_recieved == true
  check 'receive: cash_direction reports receive', rec.cash_direction == 'receive'
  check 'receive: is_paid false',                  rec.is_paid == false

  # ---------------------------------------------------------------------------
  section 'Edit -- direction is immutable (this is the old data-corruption bug)'
  # ---------------------------------------------------------------------------

  # Before the fix, `update` re-saved the typed amount without re-applying the
  # sign, so editing a Pay and entering a positive number turned it into a
  # Receive and silently moved money between columns of the cash book.
  pay.update!(amount: 999)
  pay.reload
  check 'edit pay with a positive amount stays negative', pay.amount.to_f == -999.0
  check 'edit pay keeps direction pay',                   pay.cash_direction == 'pay'
  check 'edit pay keeps is_recieved false',               pay.is_recieved == false

  rec.update!(amount: -777)
  rec.reload
  check 'edit receive with a negative amount stays positive', rec.amount.to_f == 777.0
  check 'edit receive keeps direction receive',               rec.cash_direction == 'receive'
  check 'edit receive keeps is_recieved true',                rec.is_recieved == true

  # An explicit attempt to flip the direction on an existing record must fail.
  pay.cash_direction_input = 'receive'
  pay.amount = 500
  pay.save!
  pay.reload
  check 'direction cannot be flipped on an existing record', pay.amount.to_f == -500.0

  # ---------------------------------------------------------------------------
  section 'Scopes -- each screen sees only its own records'
  # ---------------------------------------------------------------------------

  check 'cash_pays contains the pay record',      PaymentRecord.cash_pays.where(id: pay.id).exists?
  check 'cash_pays excludes the receive record',  !PaymentRecord.cash_pays.where(id: rec.id).exists?
  check 'cash_receives contains the receive rec', PaymentRecord.cash_receives.where(id: rec.id).exists?
  check 'cash_receives excludes the pay record',  !PaymentRecord.cash_receives.where(id: pay.id).exists?

  pays_ids     = PaymentRecord.cash_pays.pluck(:id)
  receives_ids = PaymentRecord.cash_receives.pluck(:id)
  check 'pay and receive scopes never overlap', (pays_ids & receives_ids).empty?

  total_custom = PaymentRecord.cash_records.count
  check 'pay + receive together cover every cash record',
        (pays_ids.size + receives_ids.size) == total_custom

  # ---------------------------------------------------------------------------
  section 'Datatable feed -- direction filter and absolute amounts'
  # ---------------------------------------------------------------------------

  params_pay = { 'length' => 100, 'start' => 0, :drawn => 1 }
  fed_pay    = PaymentRecord.cash_datatable(params_pay, 'pay')
  check 'pay datatable returns only pay records',
        fed_pay[:items].all? { |i| i.amount.to_f < 0 }
  # Strip the surrounding markup first -- the wrapper is
  # <div class="text-right">, whose class name itself contains a hyphen.
  pay_amount_texts = fed_pay[:result]['data'].map { |row| row[1].to_s.gsub(/<[^>]*>/, '') }
  check 'pay datatable renders amounts without a minus sign',
        pay_amount_texts.none? { |t| t.include?('-') }

  fed_rec = PaymentRecord.cash_datatable(params_pay, 'receive')
  check 'receive datatable returns only receive records',
        fed_rec[:items].all? { |i| i.amount.to_f >= 0 }

  check 'datatable actions column index matches the header count',
        fed_pay[:actions_col] == 3

  # ---------------------------------------------------------------------------
  section 'Totals'
  # ---------------------------------------------------------------------------

  check 'cash_total(pay) is a positive magnitude',     PaymentRecord.cash_total('pay') >= 0
  check 'cash_total(receive) is a positive magnitude', PaymentRecord.cash_total('receive') >= 0

  # ---------------------------------------------------------------------------
  section 'Labels'
  # ---------------------------------------------------------------------------

  check 'label for pay',     PaymentRecord.cash_direction_label('pay') == 'Cash - Pay'
  check 'label for receive', PaymentRecord.cash_direction_label('receive') == 'Cash - Receive'
  check 'no "Recieve" typo in labels',
        [PaymentRecord.cash_direction_label('pay'),
         PaymentRecord.cash_direction_label('receive')].none? { |l| l.include?('Recieve') }

ensure
  # ---------------------------------------------------------------------------
  # Clean up -- only ever our own rows.
  # ---------------------------------------------------------------------------
  PaymentRecord.where("note LIKE ?", "#{MARKER}%").destroy_all
  leftover = PaymentRecord.where("note LIKE ?", "#{MARKER}%").count
  puts ""
  puts "cleanup: #{leftover.zero? ? 'all test records removed' : "WARNING #{leftover} left behind"}"
end

puts ""
puts '=' * 60
if $failures.empty?
  puts "ALL #{$checks} CHECKS PASSED"
  exit 0
else
  puts "#{$failures.size} of #{$checks} CHECKS FAILED:"
  $failures.each { |f| puts "  - #{f}" }
  exit 1
end
