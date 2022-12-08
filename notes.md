- lifelog preprocessing?
  - epocs
  - eves only?
  - lineages?
- tree preprocessing????

- automatic resets
  - gem update
  - data/onehouronelife_map_reset_objects.txt
  - pl/17/automatic_resets.txt
- https://devcenter.heroku.com/articles/ruby-memory-use

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
