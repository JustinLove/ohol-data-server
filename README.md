# README

## System dependencies

Family trees use graphviz. On Heroku this requires a custom buildpack

## Database setup

- rails db:create
- rails db:migrate
- rails db:seed
- rails lives:test
- rails lives:patch_lineage

## Heroku Setup

Buildpack:

heroku buildpacks:add --index 1 https://github.com/weibeld/heroku-buildpack-graphviz.git -a app-name

2: heroku/ruby

Remove default database

heroku addons:destroy -a app-name postgresql-xxxxxxx

### Environment variables

AWS_ACCESS_KEY_ID:
AWS_REGION:
AWS_SECRET_ACCESS_KEY:
DATABASE_URL:
OUTPUT_BUCKET:

### Moving DB to RDS

docker run -it --rm postgres psql
# add mount if you need the file outside docker
PGPASSWORD=password pg_dump -h host.docker.internal -U postgres -Fc ohol-data-server_development > 2020-10-xx.dump
PGPASSWORD=xxxxxxxxxxxxxxxx pg_restore -v -h wondible-com-ohol-test-1.xxxxxxxxxxxx.us-east-1.rds.amazonaws.com -d ohol-data-server_production -U xxxxxxxxxxxxxxxx 2020-10-xx.dump
