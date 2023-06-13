#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

MESSAGE() {
  NUMBER_FORMATTED=`echo $NUMBER | sed -e "s/\s*$//g"`      
  NAME_FORMATTED=`echo $NAME | sed -e "s/\s*$//g"`
  SYMBOL_FORMATTED=`echo $SYMBOL | sed -e "s/\s*$//g"`
  TYPE_FORMATTED=`echo $TYPE | sed -e "s/\s*$//g"`
  MASS_FORMATTED=`echo $MASS | sed -e "s/\s*$//g"`
  MELTING_FORMATTED=`echo $MELTING | sed -e "s/\s*$//g"`
  BOILING_FORMATTED=`echo $BOILING | sed -e "s/\s*$//g"`
  echo "The element with atomic number $NUMBER_FORMATTED is $NAME_FORMATTED ($SYMBOL_FORMATTED). It's a $TYPE_FORMATTED, with a mass of $MASS_FORMATTED amu. $NAME_FORMATTED has a melting point of $MELTING_FORMATTED celsius and a boiling point of $BOILING_FORMATTED celsius."
}

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$1")
    if [[ -z $NUMBER ]]
    then
      echo "I could not find that element in the database."
    else
      SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number=$1") 
      NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number=$1")
      TYPE=$($PSQL "SELECT type FROM types INNER JOIN properties USING(type_id) WHERE atomic_number=$1")
      MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number=$1")
      MELTING=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number=$1")
      BOILING=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number=$1")
      MESSAGE    
    fi
  fi
  if [[ $1 =~ ^[a-zA-Z]+$ ]]
  then
    if [[ ${#1} -eq 1 || ${#1} -eq 2 ]]
    then
	    SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE symbol='$1'")
      if [[ -z $SYMBOL ]] 
    	then
      	  echo "I could not find that element in the database."
    	else
        NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$1'")
        NAME=$($PSQL "SELECT name FROM elements WHERE symbol='$1'")
        TYPE=$($PSQL "SELECT type FROM types INNER JOIN properties USING(type_id) INNER JOIN elements USING(atomic_number) WHERE symbol='$1'")
        MASS=$($PSQL "SELECT atomic_mass FROM properties INNER JOIN elements USING(atomic_number) WHERE symbol='$1'")
        MELTING=$($PSQL "SELECT melting_point_celsius FROM properties INNER JOIN elements USING(atomic_number) WHERE symbol='$1'")
        BOILING=$($PSQL "SELECT boiling_point_celsius FROM properties INNER JOIN elements USING(atomic_number) WHERE symbol='$1'")
        MESSAGE    
      fi 
    fi
    if  [[ ${#1} -gt 2 ]]
    then
	    NAME=$($PSQL "SELECT name FROM elements WHERE name='$1'")
    	if [[ -z $NAME ]] 
    	then
      	echo "I could not find that element in the database."
      else
      	NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name='$1'")
      	SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE name='$1'")
        TYPE=$($PSQL "SELECT type FROM types INNER JOIN properties USING(type_id) INNER JOIN elements USING(atomic_number) WHERE name='$1'")
        MASS=$($PSQL "SELECT atomic_mass FROM properties INNER JOIN elements USING(atomic_number) WHERE name='$1'")
        MELTING=$($PSQL "SELECT melting_point_celsius FROM properties INNER JOIN elements USING(atomic_number) WHERE name='$1'")
        BOILING=$($PSQL "SELECT boiling_point_celsius FROM properties INNER JOIN elements USING(atomic_number) WHERE name='$1'")         
        MESSAGE    
      fi
    fi
  fi
fi
