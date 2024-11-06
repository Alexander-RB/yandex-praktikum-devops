#!/bin/bash
# Скрипт развертывания backend, реализующий стратегию blue-green
BLUE_SERVICE="backend-blue"
GREEN_SERVICE="backend-green"
MAX_RETRIES=10 # Максимальное количество проверок состояния контейнера
SLEEP_INTERVAL=10 # Таймаут проверки состояния контейнера 

# Проверяю, какой контейнер запущен сейчас.
if docker --context remote ps --format "{{.Names}}" | grep -q "$BLUE_SERVICE"; then
  ACTIVE_SERVICE=$BLUE_SERVICE
  INACTIVE_SERVICE=$GREEN_SERVICE
elif docker --context remote ps --format "{{.Names}}" | grep -q "$GREEN_SERVICE"; then
  ACTIVE_SERVICE=$GREEN_SERVICE
  INACTIVE_SERVICE=$BLUE_SERVICE
else
  ACTIVE_SERVICE=""
  INACTIVE_SERVICE=$BLUE_SERVICE
fi

echo "ACTIVE_SERVICE=$ACTIVE_SERVICE"
echo "INACTIVE_SERVICE=$INACTIVE_SERVICE"

docker --context remote compose stop $INACTIVE_SERVICE

docker --context remote compose --env-file deploy.env up $INACTIVE_SERVICE -d --pull "always" --force-recreate 

# Дожидаюсь статуса healthy у нового контейнера.
for ((i=1; i<=$MAX_RETRIES; i++)); do
  CONTAINER_STATUS=`docker --context remote compose ps $INACTIVE_SERVICE --format json 2>/dev/null | jq '.Status'`
  echo $CONTAINER_STATUS
  if [[ $CONTAINER_STATUS == *"(healthy)"* ]]; then
    echo "breaking cicle"
    break
  fi
  sleep $SLEEP_INTERVAL
done

echo "ACTIVE_SERVICE=$ACTIVE_SERVICE"
echo "INACTIVE_SERVICE=$INACTIVE_SERVICE"

if [[ $CONTAINER_STATUS == *"(healthy)"* ]] && [[ ! -z "$ACTIVE_SERVICE" ]]; then
  docker --context remote compose stop $ACTIVE_SERVICE
fi