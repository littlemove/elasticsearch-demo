elastic: elasticsearch -f -D es.config=/usr/local/opt/elasticsearch/config/elasticsearch.yml
couchdb: couchdb
river: curl -XPUT 'localhost:9200/_river/couchdb_test/_meta' -d '{ "type" : "couchdb", "couchdb" : { "host" : "localhost", "port" : 5984, "db" : "couchdb_test", "filter" : null }, "index" : { "index" : "couchdb_test", "type" : "couchdb_test", "bulk_size" : "100", "bulk_timeout" : "10ms" } }'
ruby: ruby couchdb-elasticsearch.rb
