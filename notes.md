- https://devcenter.heroku.com/articles/ruby-memory-use
- query by playerid
- web api design
- unknown and not found parameters
- large family trees
- protocol buffers (or something like that)
- common query caching
  - request cache?
  - upload static files?

Test commands, need to develop to regular usage state
docker run -it --rm -e PGPASSWORD=password postgres psql -h host.docker.internal -U postgres -d ohol-data-server_development

107mb:
local: ~12min
2x: ~47min

98mb:
local: ~13min
perfm: ~39min

91mb:
perfl: ~33min

lives:
1x: ~10min
