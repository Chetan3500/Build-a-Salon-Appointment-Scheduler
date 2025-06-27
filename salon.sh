#!/bin/bash

echo -e "\n~~~~~ MY SALON ~~~~~"

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  SERVICES
}

SERVICES() {
  # message
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  # services list
  SERVICE=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICE" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  # pick service
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  # check service
  if [[ -z $SERVICE_NAME ]]
  then
    # repeat SERVICES function
    SERVICES "I could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    # check customer already registered
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      APPOINTMENTS $CUSTOMER_NAME $SERVICE_ID_SELECTED $CUSTOMER_PHONE $SERVICE_NAME
    else
      APPOINTMENTS $CUSTOMER_NAME $SERVICE_ID_SELECTED $CUSTOMER_PHONE $SERVICE_NAME
    fi
  fi
}

APPOINTMENTS() {
  echo -e "\nWhat time would you like your $4, $1?"
  read SERVICE_TIME
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$3'")
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$2', '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $4 at $(echo "$SERVICE_TIME" | sed -E 's/^ *| *$//g'), $1."
}

MAIN_MENU