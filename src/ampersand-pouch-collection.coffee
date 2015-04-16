AmpersandCollection = require 'ampersand-collection'
_ = require 'underscore'

sync = require 'ampersand-pouch-sync'

module.exports = AmpersandCollection.extend
  initialize: ->
    @sync = sync.apply @, [ @pouch ]
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
  sync: -> sync.apply @, arguments
  getOrFetch: (id, options, cb) ->
    console.log 'getOrFetch'
  fetchById: (id, cb) ->
    console.log 'fetchById'
  parse: (result) ->
    _.pluck result.rows, 'doc'
