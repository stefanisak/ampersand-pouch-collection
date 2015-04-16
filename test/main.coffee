PouchCollection = require '../ampersand-pouch-collection'
PouchModel = require 'ampersand-pouch-model'

TestModel = PouchModel.extend
  idAttribute: '_id'
  pouch:
    dbName: 'test_database'
  props:
    title: 'string'

TestCollection = PouchCollection.extend
  mainIndex: '_id'
  model: TestModel
  pouch:
    dbName: 'test_database'
    options:
      query:
        include_docs: true,
        fun:
          map: (doc) -> emit doc._id, null

test 'check method existence', (done) ->
  pouchCollection = new PouchCollection
  pouchCollection.fetch.should.be.ok
  pouchCollection.create.should.be.ok
  pouchCollection.sync.should.be.ok
  pouchCollection.getOrFetch.should.be.ok
  pouchCollection.fetchById.should.be.ok
  done()
