if test -f .env; then
  source .env
fi

DOCKER_COMPOSE="${DOCKER_COMPOSE}"
if [ -z "$DOCKER_COMPOSE" ]; then
  if [ -n "`which docker-compose`" ]; then
    DOCKER_COMPOSE=docker-compose
  else
    # invoking 'docker compose' rarely works for devs, so test before falling back to this
    docker compose > /dev/null 2>&1
    if [ $? -eq 0 ]; then
      DOCKER_COMPOSE=docker\ compose
    else
      echo "Unable to resolve 'docker compose' or 'docker-compose' command.  Try 'brew install docker-compose' to fix."
      exit 1
    fi
  fi
fi
