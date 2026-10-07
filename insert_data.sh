#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

team_values=""
game_values=""
while IFS=, read -r year round winner opponent winner_goals opponent_goals
do
  [[ $year == "year" ]] && continue

  if [[ -n $team_values ]]
  then
    team_values+=", "
    game_values+=", "
  fi

  team_values+="('$winner'), ('$opponent')"
  game_values+="($year, '$round', '$winner', '$opponent', $winner_goals, $opponent_goals)"
done < games.csv

$PSQL "INSERT INTO teams(name)
SELECT DISTINCT name
FROM (VALUES $team_values) AS team_names(name)
ON CONFLICT (name) DO NOTHING;
INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)
SELECT game.year, game.round, winner.team_id, opponent.team_id, game.winner_goals, game.opponent_goals
FROM (VALUES $game_values) AS game(year, round, winner, opponent, winner_goals, opponent_goals)
JOIN teams AS winner ON winner.name = game.winner
JOIN teams AS opponent ON opponent.name = game.opponent;"
