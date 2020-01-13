FROM virtualstaticvoid/heroku-docker-r:shiny
ENV PORT=8080
CMD "R --no-save -f /app/run.R"