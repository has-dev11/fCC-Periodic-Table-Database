#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align --quiet"

if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

# Escape single quotes in user input for safe SQL string matching
ESCAPED_INPUT=${1//\'/\'\'}

QUERY_RESULT=$($PSQL -c "
SELECT
  e.atomic_number || '|' ||
  e.name || '|' ||
  e.symbol || '|' ||
  t.type || '|' ||
  (p.atomic_mass::real)::text || '|' ||
  p.melting_point_celsius || '|' ||
  p.boiling_point_celsius
FROM elements e
INNER JOIN properties p ON e.atomic_number = p.atomic_number
INNER JOIN types t ON p.type_id = t.type_id
WHERE e.atomic_number::text = '$ESCAPED_INPUT'
   OR LOWER(e.symbol) = LOWER('$ESCAPED_INPUT')
   OR LOWER(e.name) = LOWER('$ESCAPED_INPUT')
LIMIT 1;
")

if [[ -z $QUERY_RESULT ]]; then
  echo "I could not find that element in the database."
  exit 0
fi

IFS="|" read -r ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING BOILING <<< "$(echo "$QUERY_RESULT" | tr -d '\r' | xargs)"

echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius." 