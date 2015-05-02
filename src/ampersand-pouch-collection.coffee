AmpersandCollection = require 'ampersand-collection'
_ = require 'underscore'

sync = require 'ampersand-pouch-sync'

module.exports = AmpersandCollection.extend
  initialize: -> @sync = sync.apply @, [ @pouch ]
  getPouchDB: -> @sync.pouchDB
  fetch: (options) ->
    options = options || {}
    options.parse = true unless options.parse?
    success = options.success
    me = @
    options.success = (response) ->
      if options.reset then method = 'reset' else method = 'set'
      me[method] response, options
      if success then success me, response, options
      me.trigger 'sync', me, response, options
    @sync 'read', @, options
  create: (model, options) ->
    options = options || {}
    unless (model = @_prepareModel(model, options)) then return false
    collection = @
    success = options.success
    options.success = (model, resp) ->
      collection.add model, options
      if success then success model, resp, options
    model.save null, options
    model
  getOrFetch: (id, options, cb) ->
    if arguments.length isnt 3
      cb = options
      options = {}
    self = @
    model = @get id
    if model then return cb null, model
    done = ->
      model = self.get id
      if model
        if cb then cb null, model
        else cb new Error 'not found'
    if options.all
      options.success = done
      options.error = done
      return @fetch options
    else return @fetchById id, cb
  fetchById: (id, cb) ->
    me = @
    idObj = {}
    idObj[@model.prototype.idAttribute] = id
    model = new @model idObj, {collection: @}
    model.fetch
      success: ->
        me.add model
        if cb then cb null, model
      error: ->
        delete model.collection
        if cb then cb Error 'not found'
  parse: (result) ->
    _.pluck result.rows, 'doc'
