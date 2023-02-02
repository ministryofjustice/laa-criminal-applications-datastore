#!/bin/sh
cd /usr/src/app 2> /dev/null

ACTION=$1
RETRY_LIMIT=3
RETRY_FREQUENCY=2
PIDFILE=tmp/pids/shoryuken.pid

start_function(){
  SHORYUKEN_PID=$(cat $PIDFILE 2> /dev/null)

  if [ -z "$SHORYUKEN_PID" ]; then
    bundle exec shoryuken -R -C config/shoryuken.yml
  else
    echo "Shoryuken may already be running with PID $SHORYUKEN_PID"
  fi
}

stop_function(){
  # SIGTERM triggers a quick exit; gracefully terminate instead.
  SHORYUKEN_PID=$(cat $PIDFILE 2> /dev/null)

  if [ -z "$SHORYUKEN_PID" ]; then
    echo "No Shoryuken PID found."
  else
    echo "Sending USR1 signal..."
    kill -USR1 ${SHORYUKEN_PID}

    wait_function ${SHORYUKEN_PID}

    # Ensure it has shutdown and clear PID file
    if ps -p "$SHORYUKEN_PID" > /dev/null; then
      echo "Waited too long. Forcing TERM signal..."
      kill -TERM "$SHORYUKEN_PID"
    fi

    rm -rf "$PIDFILE"
  fi
}

wait_function(){
  SHORYUKEN_PID=$1

  sleep 1
  i=0
  while [ ${i} -lt ${RETRY_LIMIT} ]; do
    i=$((i+1))

    if ps -p "$SHORYUKEN_PID" > /dev/null; then
      echo "Shoryuken is still busy. Retry $i/$RETRY_LIMIT Waiting $RETRY_FREQUENCY seconds..."
      sleep ${RETRY_FREQUENCY}
    else
      echo "Shoryuken was successfully shutdown."
      break
    fi
  done
}



case "$ACTION" in
  start)
    start_function
    ;;
  stop)
    stop_function
    ;;
  restart)
    stop_function && start_function
    ;;
  *)
  echo "Usage: $0 [start|stop|restart]"
esac
