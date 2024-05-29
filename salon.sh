#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo "Welcome to The Salon, How can I help you?"

  AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services")

  echo "$AVAILABLE_SERVICES" | while IFS='|' read -r SERVICE_ID NAME 
  do
    SERV_ID=$(echo $SERVICE_ID | sed 's/ //g')
    SERV=$(echo $NAME | sed 's/ //g')
    echo "$SERV_ID) $SERV"
  done
  read SERVICE_ID_SELECTED
  case $SERVICE_ID_SELECTED in
    [1-4]) SET_APPOINTMENT;;
        *) MAIN_MENU "Service Not Found Pick Again: " ;;
  esac


}

SET_APPOINTMENT() {
  echo -e "\n What is your phone number?:"
  read CUSTOMER_PHONE

  NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CUSTOMER_NAME=$(echo $NAME | sed 's/ //g')

  if [[ -z $NAME ]]
  then
    echo -e "\nThere is no existing profile with that number.. \n Whats your name?"
    read CUSTOMER_NAME
    SAVED_TO_TABLE_CUSTOMERS=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
  fi

  GET_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  SERVICE_NAME=$(echo $GET_SERVICE_NAME | sed 's/ //g')
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  

  echo -e "\nWhat time would you like your $SERVICE_NAME:"
  read SERVICE_TIME
  INSERT_INTO_TABLE=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  if [[ $INSERT_INTO_TABLE == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi





}

MAIN_MENU