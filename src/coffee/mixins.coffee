_ = require 'underscore'

###*
 * A collection of methods to be used as underscore mixins
 * @example
 *   _ = require 'underscore'
 *   _.mixin require('underscore-mixins')
###
module.exports =

  ###*
   * Returns a deep clone of the given object
   * @param {Object} obj A JSON object
   * @return {Object} A deep clone of the given object
  ###
  deepClone: (obj) ->
    return {} unless obj
    JSON.parse(JSON.stringify(obj))

  ###*
   * Stringifies a JSON object in a pretty format.
   * In case of a non JSON object, the argument itself is returned (also for Error instances).
   * @param {Object} obj A JSON object
   * @param {Number} [indentation] The indentation number (default 2)
   * @return {String} A pretty string
  ###
  prettify: (obj, indentation = 2) ->
    return unless obj
    switch
      when obj instanceof Error then obj
      when _.isObject(obj) then JSON.stringify obj, null, indentation
      else obj

  ###*
   * Returns the percentage of the given values
   * @param {Number} x The current number out of total
   * @param {Number} tot The total number to calculate the percentage
   * @return {Number} The percentage value, rounded
  ###
  percentage: (x, tot) -> Math.round(x * 100 / tot)

  ###*
   * Returns a URL query string from a key-value object
   * @param {Object} params A JSON object containing key-value query params
   * @return {String} A query string, or empty if params is undefined
  ###
  stringifyQuery: (params) ->
    return "" unless params
    query = _.reduce params, (memo, value, key) ->
      _.each _.flatten([value]), (v) -> memo.push "#{key}=#{v}"
      memo
    , []
    query.join("&")

  ###*
   * Returns a key-value JSON object from a query string
   * @param {String} query A query string
   * @param {Boolean} hasUniqueParams Will determine the parsing strategy in case
   *                                  of multiple parameters with the same key (default 'true')
   *                                  - `true` (default): same parameter key will be overridden
   *                                  - `false`: same parameters values will be put in an array
   *                                  Example:
   *                                    query = 'foo=bar1&foo=bar2'
   *                                    # => {foo: ['bar1', 'bar2']}
   * @return {Object} A JSON object (note that all values are parsed as string)
  ###
  parseQuery: (query, hasUniqueParams = true) ->
    return {} unless query
    _.reduce query.split('&'), (memo, param) ->
      splitted = param.split('=')
      return memo if _.size(splitted) < 2
      # we always get the first splitted part as the key
      key = splitted[0]
      # the value is then just the param - key
      value = param.replace("#{key}=", '')
      # if key already exists
      # - override it with new value
      # - put values in an array, if explicitly asked
      if _.has(memo, key) and not hasUniqueParams
        currentValue = memo[key]
        memo[key] = _.flatten([currentValue].concat(value))
      else
        memo[key] = value
      memo
    , {}

  ###*
   * Transform a given list in a new nested list of single list elements (batches)
   * given max size.
   * Useful if you need to process some elements on a list, but not all together.
   * @param  {Array} list The original list
   * @param  {Int} size The size of the nested lists to group the elements to
   * @return {Array} A new list with nested batch lists of given size
   * @throws {Error} If size is not defined
   * @example
   *   list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]
   *   console.log _.batchList(list, 3)
   *   # => [[1, 2, 3], [4, 5, 6], [7, 8, 9], [0]]
  ###
  batchList: (list, size) ->
    throw new Error 'List batch size is required' unless size
    batch = []
    group = -1
    for i in [0...list.length]
      mod = i % size
      if mod == 0
        batch.push([])
        group++
      batch[group][mod] = list[i]
    batch