#!/bin/bash


# Starting docker

echo "Starting docker containers"
docker stop postgres
docker stop meilisearch
docker rm postgres
docker rm meilisearch

# Run docker-compose up -d and redirect stderr to a temporary file
docker-compose up -d 2> /tmp/docker_error.txt

# Wait for all services to be healthy
docker-compose wait

curl -X POST -H 'Content-type: application/xml' --data-binary '@/schema.xml' http://localhost:8983/solr/ePaperless/schema


echo "Postgres docker created"
echo "Solr docker created"
echo "'ePaperless' Solr core created"


# Starting the Backend


# Change directory
cd ../ePaperless_BE/ || {
  echo "Error: Could not change directory to $dir"
  exit 1
}

source venv/bin/activate || true  # Suppress potential errors if venv is not present

echo "Virtual environment activated"

pip freeze > requirements.txt 2>/dev/null  # Redirect stderr to /dev/null to suppress potential output / to be removed in production


# Kill process on port 8000 (optional)
echo "# Killing process on port 8000 (if any)"

# Identify process ID (PID)
process_id=$(lsof -t -i :8000 | awk '{print $2}')

# Check if process ID exists
if [[ ! -z "$process_id" ]]; then
  # Display information about conflicting process
  echo "A process (PID: $process_id) is already using port 8000."
  read -p "Kill this process and continue? (y/N): " answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    # Kill the process using its PID
    kill $process_id
    echo "Killed process with PID: $process_id"
  else
    echo "Process not killed. Please manually stop the conflicting process using PID: $process_id and re-run the script."
    exit 1  # Exit script with error code to indicate user intervention needed
  fi
else
  echo "No process found running on port 8000."
fi


echo "...........:;***********+;;:,,....................,*?:...................................."
echo ".............,:+*********??*+;*,..................+?*,...................................."
echo "................,;+*******+;,*SS+,...............;*?%;...................................."
echo "...................,;***;:,,;%%SS%;.............:??%%?...................................."
echo ".....................,::,,,:?%%SSSS%;..........,?%%%%%:..................................."
echo ".......................,,,,+%%%SSSSSS?:.......,*%%%%%%*..................................."
echo ".......................,,,:?%%%SSSSSSSS*,.....:%%%%%%%%:.................................."
echo "........................,,*%%%%SSSSSSSSSS+,...+%%%%%%%%*,:::::::::,,......................"
echo "........................,;%%%%%%SSSSSSSSSS%;..?%%%%%%%%*;++++;:::::;:,...................."
echo ".........................*%%%%%%SSSSSSSSSSSS?;%%%%%%%*+++***+;+;;:::;;;:.................."
echo ".........................,*%%%%%SSSSSSSSSSSSSSS%%%%?++******;;+++++;;:;+,................."
echo "...........................+%%%%SSSSSSSSSSSSSSSSS?*********+:;+;;+++**??;................."
echo "............................:?%%%SSSSSSSSSSSSSS%?++********;:;+**?%%%%%%?:................"
echo ".............................,?%%SSSSSSSSSS%%%%?+++++*****+:+*???*+;:::;+**;,............."
echo "..............................,*%SSSSSSS%%%%%%%+;+++++++**++*+;:,........,;**+:..........."
echo "................................;SSS%%%%%%%%%%*;+++++++++++;,...............,;++:,........"
echo "...............................,:*??%%%%%%%%%?+++++++++;;;:....................,;+;,......"
echo "..............................:**+++*?%%%%%%?++++++;;;;;;,........................:;;:,..."
echo "............................:**+++++++**?%%?*+++;;;;;;;:,...........................,,:,,."
echo "..........................:+?*+++++++++++**+;;;;;;;;;;:................................,,,"
echo "........................:+??*+++++++++;;;:::::;;;;;;;,...................................."
echo "......................,+???*+++++;;;:::::::::::;;;;:,....................................."
echo "....................,+????*++;;;;;;;;;+++++;;;::,,........................................"
echo "...................,*?****++++++**++++;::,,,.............................................."
echo "...................,*****+;;+++;;:,,,....................................................."
echo "...................,*****+;;;:............................................................"
echo "...................,*****;;;;,............................................................"
echo "...................,****+;;;,............................................................."
echo "...................,****;;;,.............................................................."
echo "...................,***+;+:..............................................................."
echo "...................,***+;;................................................................"
echo "...................,***;;,................................................................"
echo "...................,**+;,................................................................."
echo "...................,**;:.................................................................."
echo "...................,*+:..................................................................."
echo "...................,*;...................................................................."
echo "...................,+,...................................................................."
echo "...................,,....................................................................."



# Run uvicorn in the background with live reload
# uvicorn main:app --reload &  # Append "&" to run in the background
uvicorn main:app --reload || {
  echo "failed stating uvicorn"
  exit 1
}
echo "runnng uvicorn"

# Inform the user of successful execution
echo "Successfully executed commands. ePaperless backend is running."




