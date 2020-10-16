- new db host
- separate tables
  - x created names
  - x updated name queries
  - x import names to separate table
  - x remove names from lives
  - x create accounts
  - x upate hashs queries
  - x import hashes to separate table
  - x delete hash from lives - remove hash from import
- web api design
- unknown and not found parameters
- large family trees
- protocol buffers (or something like that)
- common query caching
  - request cache?
  - upload static files?

Test commands, need to develop to regular usage state
docker run -it --rm -e PGPASSWORD=password postgres psql -h host.docker.internal -U postgres -d ohol-data-server_development
