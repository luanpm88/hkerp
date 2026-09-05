#!/usr/bin/env bash
#
# HTTP smoke test for the Cash - Pay / Cash - Receive split.
#
#   BASE_URL=http://localhost:3000 EMAIL=... PASSWORD=... ./script/smoke_cash_split.sh
#
# Drives a real browser session (Devise login + CSRF) against a running
# instance and checks the pages, the create flow, the datatable feed and the
# legacy redirects. Records it creates are tagged SMOKE_CASH_SPLIT so they can
# be identified and removed afterwards.
#
# Point it at the Docker development stack — never at production.

set -uo pipefail

BASE_URL="${BASE_URL:-http://localhost:3000}"
EMAIL="${EMAIL:?set EMAIL}"
PASSWORD="${PASSWORD:?set PASSWORD}"

# The create checks insert real rows into the cash book. That is fine against
# the local Docker stack, where they can be deleted again straight afterwards,
# but it must never happen silently against a shared or production instance.
# Writes are therefore enabled only for a localhost target unless the operator
# explicitly opts in with ALLOW_WRITES=1.
case "$BASE_URL" in
  http://localhost*|http://127.0.0.1*) IS_LOCAL=1 ;;
  *)                                   IS_LOCAL=0 ;;
esac
ALLOW_WRITES="${ALLOW_WRITES:-$IS_LOCAL}"

JAR="$(mktemp)"
TMP="$(mktemp -d)"
trap 'rm -rf "$JAR" "$TMP"' EXIT

PASSES=0
FAILS=0

pass() { printf '  ok    %s\n' "$1"; PASSES=$((PASSES + 1)); }
fail() { printf '  FAIL  %s\n' "$1"; FAILS=$((FAILS + 1)); }

check() { # desc, condition-exit-code
  if [ "$2" -eq 0 ]; then pass "$1"; else fail "$1"; fi
}

section() { printf '\n%s\n%s\n' "$1" "$(printf '%*s' "${#1}" '' | tr ' ' '-')"; }

get()  { curl -sS -b "$JAR" -c "$JAR" -L "$BASE_URL$1" -o "$2" -w '%{http_code}' 2>/dev/null; }
code() { curl -sS -b "$JAR" -c "$JAR" -o /dev/null -w '%{http_code}' "$BASE_URL$1" 2>/dev/null; }
# Status of the FIRST response, without following redirects.
raw_code() { curl -sS -b "$JAR" -c "$JAR" -o /dev/null -w '%{http_code}' "$BASE_URL$1" 2>/dev/null; }
location() { curl -sS -b "$JAR" -c "$JAR" -o /dev/null -D - "$BASE_URL$1" 2>/dev/null | tr -d '\r' | awk 'tolower($1)=="location:"{print $2}'; }

csrf_from() { # file -> token
  grep -o 'name="authenticity_token"[^>]*value="[^"]*"' "$1" | head -1 | sed 's/.*value="//; s/".*//'
}

# ---------------------------------------------------------------------------
section 'Login'
# ---------------------------------------------------------------------------

get /users/sign_in "$TMP/login.html" >/dev/null
TOKEN="$(csrf_from "$TMP/login.html")"
[ -n "$TOKEN" ]; check 'sign-in page returns a CSRF token' $?

curl -sS -b "$JAR" -c "$JAR" -L -o "$TMP/after_login.html" \
     --data-urlencode "authenticity_token=$TOKEN" \
     --data-urlencode "user[email]=$EMAIL" \
     --data-urlencode "user[password]=$PASSWORD" \
     "$BASE_URL/users/sign_in" >/dev/null 2>&1
! grep -qi 'Invalid\|sign_in' "$TMP/after_login.html"; check 'logged in' $?

# ---------------------------------------------------------------------------
section 'Both screens render and are clearly distinct'
# ---------------------------------------------------------------------------

get /payment_records/cash_pays "$TMP/pays.html" >/dev/null
grep -q 'Cash - Pay' "$TMP/pays.html"; check 'Cash - Pay page shows its own title' $?
grep -q 'money going <strong>out</strong>' "$TMP/pays.html"; check 'Cash - Pay explains the direction' $?
grep -q 'data-direction="pay"' "$TMP/pays.html"; check 'Cash - Pay datatable is scoped to pay' $?

get /payment_records/cash_receives "$TMP/recs.html" >/dev/null
grep -q 'Cash - Receive' "$TMP/recs.html"; check 'Cash - Receive page shows its own title' $?
grep -q 'money coming <strong>in</strong>' "$TMP/recs.html"; check 'Cash - Receive explains the direction' $?
grep -q 'data-direction="receive"' "$TMP/recs.html"; check 'Cash - Receive datatable is scoped to receive' $?

! grep -q 'Recieve' "$TMP/pays.html";  check 'no "Recieve" typo on the Pay screen' $?
! grep -q 'Recieve' "$TMP/recs.html"; check 'no "Recieve" typo on the Receive screen' $?

# ---------------------------------------------------------------------------
section 'Forms no longer offer a direction to get wrong'
# ---------------------------------------------------------------------------

get /payment_records/new_cash_pay "$TMP/new_pay.html" >/dev/null
grep -q 'Cash - Pay' "$TMP/new_pay.html"; check 'new Pay form is labelled Cash - Pay' $?
! grep -q 'name="is_recieved"' "$TMP/new_pay.html"; check 'new Pay form has NO direction dropdown' $?
! grep -qi '<option[^>]*>Recieve<' "$TMP/new_pay.html"; check 'new Pay form has no Recieve option' $?

get /payment_records/new_cash_receive "$TMP/new_rec.html" >/dev/null
grep -q 'Cash - Receive' "$TMP/new_rec.html"; check 'new Receive form is labelled Cash - Receive' $?
! grep -q 'name="is_recieved"' "$TMP/new_rec.html"; check 'new Receive form has NO direction dropdown' $?

# ---------------------------------------------------------------------------
section 'Creating through each screen'
# ---------------------------------------------------------------------------

# Pull the first real option out of the payment-method select on the new-Pay
# form. Restricting to that select matters — the bank-account select on the
# same page also has numeric option values.
METHOD_ID="$(awk '/payment_record\[payment_method_id\]/,/<\/select>/' "$TMP/new_pay.html" \
             | grep -o 'value="[0-9][0-9]*"' | head -1 | tr -dc '0-9')"
[ -n "$METHOD_ID" ]; check "found a payment method to post with (id=$METHOD_ID)" $?

post_cash() { # path, amount, note -> writes $TMP/created.html
  local path="$1" amount="$2" note="$3" form="$4"
  local token; token="$(csrf_from "$form")"
  curl -sS -b "$JAR" -c "$JAR" -L -o "$TMP/created.html" \
       --data-urlencode "authenticity_token=$token" \
       --data-urlencode "payment_record[amount]=$amount" \
       --data-urlencode "payment_record[note]=$note" \
       --data-urlencode "payment_record[payment_method_id]=$METHOD_ID" \
       --data-urlencode "payment_record[paid_date]=$(date +%Y-%m-%d)" \
       "$BASE_URL$path" >/dev/null 2>&1
}

if [ "$ALLOW_WRITES" = "1" ]; then
  post_cash /payment_records/create_cash_pay 123456 'SMOKE_CASH_SPLIT pay' "$TMP/new_pay.html"
  ! grep -qi 'prohibited this record' "$TMP/created.html"; check 'Pay record created without validation errors' $?

  post_cash /payment_records/create_cash_receive 654321 'SMOKE_CASH_SPLIT receive' "$TMP/new_rec.html"
  ! grep -qi 'prohibited this record' "$TMP/created.html"; check 'Receive record created without validation errors' $?
else
  printf '  --    skipped: %s is not local, so no rows are written\n' "$BASE_URL"
  printf '        (re-run with ALLOW_WRITES=1 to include the create checks)\n'
fi

# ---------------------------------------------------------------------------
section 'Datatable feed is filtered by direction'
# ---------------------------------------------------------------------------

get '/payment_records/cash_datatable?direction=pay&length=100&start=0' "$TMP/dt_pay.json" >/dev/null
grep -q '"recordsTotal"' "$TMP/dt_pay.json"; check 'pay datatable returns JSON' $?
# A rendered amount always follows the opening <div>, so a negative one would
# appear as `>-`. Matching on the bare pattern `-[0-9]` would false-positive on
# the paid_date column (2026-09-05) and on the class name "text-right".
! grep -q -- '>-' "$TMP/dt_pay.json"
check 'pay datatable shows amounts without a minus sign' $?

get '/payment_records/cash_datatable?direction=receive&length=100&start=0' "$TMP/dt_rec.json" >/dev/null
grep -q '"recordsTotal"' "$TMP/dt_rec.json"; check 'receive datatable returns JSON' $?

PAY_TOTAL="$(grep -o '"recordsTotal":[0-9]*' "$TMP/dt_pay.json" | head -1 | sed 's/[^0-9]//g')"
REC_TOTAL="$(grep -o '"recordsTotal":[0-9]*' "$TMP/dt_rec.json" | head -1 | sed 's/[^0-9]//g')"
[ -n "$PAY_TOTAL" ] && [ -n "$REC_TOTAL" ] && [ "$PAY_TOTAL" -ne "$REC_TOTAL" ]
check "pay ($PAY_TOTAL) and receive ($REC_TOTAL) counts differ, so the filter is applied" $?

# ---------------------------------------------------------------------------
section 'Legacy URLs still land somewhere sensible'
# ---------------------------------------------------------------------------

LOC="$(location /payment_records/custom_payments)"
printf '%s' "$LOC" | grep -q 'cash_pays'; check "old custom_payments redirects to cash_pays ($LOC)" $?

LOC="$(location /payment_records/pay_custom)"
printf '%s' "$LOC" | grep -q 'new_cash_pay'; check "old pay_custom redirects to new_cash_pay ($LOC)" $?

# ---------------------------------------------------------------------------
section 'Menu'
# ---------------------------------------------------------------------------

grep -q '>Cash - Pay<' "$TMP/pays.html";     check 'sidebar has a Cash - Pay entry' $?
grep -q '>Cash - Receive<' "$TMP/pays.html"; check 'sidebar has a Cash - Receive entry' $?
! grep -q 'Custom Pay/Recieve' "$TMP/pays.html"; check 'old combined menu entry is gone' $?

# ---------------------------------------------------------------------------
section 'Cleanup'
# ---------------------------------------------------------------------------

# The create checks insert real rows. Remove them so repeated runs do not
# accumulate junk in the cash book. Only rows this script created are touched.
#
# The cleanup talks to the local Docker database, so it is only correct when
# the run itself targeted that same stack — deleting from Docker after testing
# a remote host would leave the remote rows behind while reporting success.
if [ "$ALLOW_WRITES" != "1" ]; then
  printf '  --    nothing to clean: no rows were written\n'
elif [ "$IS_LOCAL" = "1" ] && command -v docker >/dev/null 2>&1 && docker compose ps db >/dev/null 2>&1; then
  docker compose exec -T db psql -U hoangkhang -d hkerp_development -qtAc \
    "DELETE FROM payment_records WHERE note LIKE 'SMOKE_CASH_SPLIT%';" >/dev/null 2>&1
  LEFT="$(docker compose exec -T db psql -U hoangkhang -d hkerp_development -tAc \
    "SELECT count(*) FROM payment_records WHERE note LIKE 'SMOKE_CASH_SPLIT%';" 2>/dev/null | tr -d '[:space:]')"
  [ "$LEFT" = "0" ]; check 'smoke records removed from the database' $?
else
  fail "rows were written to $BASE_URL and must be removed by hand"
  printf "        DELETE FROM payment_records WHERE note LIKE 'SMOKE_CASH_SPLIT%%';\n"
fi

# ---------------------------------------------------------------------------
printf '\n%s\n' '============================================================'
if [ "$FAILS" -eq 0 ]; then
  printf 'ALL %d SMOKE CHECKS PASSED\n' "$PASSES"
  exit 0
else
  printf '%d of %d SMOKE CHECKS FAILED\n' "$FAILS" "$((PASSES + FAILS))"
  exit 1
fi
