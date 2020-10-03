- new db host
- separate tables
  - x created names
  - x updated name queries
  - x import names to separate table
  - x remove names from lives
  - x create accounts
  - x upate hashs queries
  - import hashes to separate table
  - delete hash from lives
- web api design
- unknown and not found parameters
- large family trees
- protocol buffers (or something like that)
- common query caching
  - request cache?
  - upload static files?



Test commands, need to develop to regular usage state
docker run --rm -it -p 5432:5432 --mount source=oholdataserver1,target=/var/lib/postgresql/data -e POSTGRES_PASSWORD=password postgres
docker run -it --rm -e PGPASSWORD=password postgres psql -h host.docker.internal -U postgres -d ohol-data-server_development
docker run -it --rm -e PGPASSWORD=password postgres pg_dump -h host.docker.internal -U postgres -Fc ohol-data-server_development > 2020-10-02.dump
