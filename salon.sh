#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

echo -e "\nWelcome to My Salon, how can I help you?\n"

#declare global variables
CUSTOMER_NAME = ""
CUSTOMER_PHONE = ""
SERVICES = $($PSQL "SELECT service_id, name FROM services")
SERVICE_ID_SELECTED = 0
SERVICE_TIME = ""
SERVICE_NAME_FORMATTED = ""
CUSTOMER_NAME_FORMATTED = ""


# Next create some functions to processing data
FORMAT_NAMES () {

    SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/\s//g' -E)
    CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/\s//g' -E)

}

GET_PHONE () {

    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

}

CHECK_CUSTOMER () {

    # Now we check if your database hold current customer. 
    # if it isn't here, created him

    HAS_CUSTOMER = $(PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    if [[ -z $HAS_CUSTOMER ]]
    then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME

        INSERTED=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    
    if

    # also we need to format names to display it correctly
    FORMAT_NAMES

}

GET_TIME () {
    
    echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
    read SERVICE_TIME

}

INSERT_DATA () {

    #get customer ID to insert valid data
    CUSTOMER_ID = $(PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    #insert data to valid table
    INSERTED=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."

}


DISPLAY_SERVICES () {

    # get services list to display it for customer
    SERVICE_NAME = $(PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

    echo "$SERVICES" | while read SERVICE_ID BAR NAME
    do
        echo "$SERVICE_ID) $NAME"
    done

}

PROCESS_CUSTOMER () {
    
    # at first, get users phone number
    GET_PHONE

    # then check him into our database
    # if it isn't here, add him
    CHECK_CUSTOMER

    # next we neet to set up time 
    GET_TIME

    # finally, we neet to insert data to database
    INSERT_DATA

}
# --- END FUNCTIONS ----

# --- MAIN SECTION ---
LIST_DATA () {

    # if we pass some message, display it
    if [[ $1 ]]
    then
        echo -e "\n$1"
    fi

    # Display valid services
    DISPLAY_SERVICES

    # get user choice
    read SERVICE_ID_SELECTED

    # check if it's a number
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]

    then
        LIST_DATA "I could not find that service. What would you like today?"

    else 

        # check if service is valid
        HAS_SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")

        if [[ -z $HAS_SERVICE ]]

        then
            LIST_DATA "I could not find that service. What would you like today?"

        else
            PROCESS_CUSTOMER

        fi

    fi

}

LIST_DATA
