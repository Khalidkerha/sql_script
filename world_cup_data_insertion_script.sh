#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=postgres --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
if [[ $YEAR == "year" && $ROUND == "round" && $WINNER == "winner" && $OPPONENT == "opponent" && $WINNER_GOALS == "winner_goals" && $OPPONENT_GOALS == "opponent_goals" ]]; then
    echo "Skipping header row"
    continue
  fi
  # Get team IDs from the database
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

  # Insert opponent if not found
  if [[ -z $OPPONENT_ID ]]
  then
    INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
    if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserted into teams: $OPPONENT"
    fi
    # Get new opponent_id after insertion
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  fi

  # Insert winner if not found
  if [[ -z $WINNER_ID ]]
  then
    INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
    if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserted into teams: $WINNER"
    fi
    # Get new winner_id after insertion
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  fi
   GAME_ID=$($PSQL "SELECT game_id FROM games WHERE year=$YEAR AND round='$ROUND' AND winner_id=$WINNER_ID AND opponent_id=$OPPONENT_ID")
  echo "GAME_ID: $GAME_ID"

  if [[ -z $GAME_ID ]]; then
    # Insert game data
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, winner_id, opponent_id, winner_goals, opponent_goals, round) VALUES($YEAR, $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS, '$ROUND')")
    echo "INSERT_GAME_RESULT: $INSERT_GAME_RESULT"
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]; then
      echo "Inserted into games: Winner=$WINNER, Opponent=$OPPONENT, Year=$YEAR, Round=$ROUND"
    fi
  fi
  # Now you can use the OPPONENT_ID and WINNER_ID for further operations, like inserting game data.
done
