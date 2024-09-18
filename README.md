Start app:

 1. sudo docker-compose down && sudo docker-compose build --no-cache && sudo docker-compose up 
    OR 
    docker-compose down && docker-compose build --no-cache && docker-compose up
    (depends of docker installation)
 2. Create postgre db with ./priv/db.sql and change sys.config with you db connection values, than run 'rebar3 shell'

Swagger doc: http://localhost:8080/api-docs/index.html#

App flow:
  1. Create user with PUT /api/v1/users
  2. Get user id with GET /api/v1/users
  3. Create first plan(todo in HA) with PUT /api/v1/plans
  4. Check created plan with GET /api/v1/plans
  5. You can change plan status with PATCH /api/v1/plans (todo, progress and complete value available)
  6. Check updated plan with GET /api/v1/plans
  7. You can delete users and plans with DELETE /api/v1/users for users and DELETE /api/v1/plans for plans

