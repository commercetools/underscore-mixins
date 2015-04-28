_ = require 'underscore'
_.mixin require('underscore.string').exports()
_m = require '../lib/mixins'

describe 'Mixins', ->

  describe 'underscore.string', ->

    it 'should mix in with underscore without conflicts', ->
      u = _.union [{key: 'foo'}, {key: 'bar'}, {key: 'qux'}], [], []
      expect(u).toEqual [{key: 'foo'}, {key: 'bar'}, {key: 'qux'}]

  describe '_m', ->

    it 'should extend underscore', ->
      _.mixin _m
      expect(_.deepClone).toBeDefined()
      expect(_.prettify).toBeDefined()
      expect(_.percentage).toBeDefined()
      expect(_.stringifyQuery).toBeDefined()
      expect(_.parseQuery).toBeDefined()

  describe '_m :: deepClone', ->

    it 'should clone an object deeply', ->
      obj =
        a: [
          {one: "One"}
          {two: "Two"}
          {three: "Three"}
        ]
        b:
          c:
            d:
              e:
                f:
                  g: [
                    {one: "One"}
                    {two: "Two"}
                    {three: "Three"}
                  ]
      expectedObj =
        a: [
          {one: "One"}
          {two: "Two"}
          {three: "Three"}
        ]
        b:
          c:
            d:
              e:
                f:
                  g: [
                    {one: "One"}
                    {two: "Two"}
                    {three: "Three"}
                  ]
      expect(_m.deepClone(obj)).toEqual expectedObj

  describe '_m :: prettify', ->

    it 'should prettify JSON', ->
      expect(_m.prettify {foo: 'bar'}).toBe '{\n  "foo": "bar"\n}'

    it 'should prettify JSON with custom indentation', ->
      expect(_m.prettify {foo: 'bar'}, 4).toBe '{\n    "foo": "bar"\n}'

    it 'should return error instance', ->
      e = new Error 'foo'
      expect(_m.prettify e).toEqual e

    it 'should return if no argument is given', ->
      expect(_m.prettify()).not.toBeDefined()

    it 'should return argument itself if not an object nor an error', ->
      expect(_m.prettify 'foo').toBe 'foo'
      expect(_m.prettify 10).toBe 10

  describe '_m :: percentage', ->

    it 'should calculate value', ->
      expect(_m.percentage 10, 100).toBe 10

    it 'should calculate rounded value', ->
      expect(_m.percentage 33, 1010).toBe 3

  describe '_m :: stringifyQuery', ->

    it 'should parse string from object', ->
      query = _m.stringifyQuery
        where: encodeURIComponent('name(en = "Foo")')
        staged: true
        limit: 100
        offset: 2

      expect(query).toBe 'where=name(en%20%3D%20%22Foo%22)&staged=true&limit=100&offset=2'

    it 'should parse string from object (with multiple params)', ->
      query = _m.stringifyQuery
        filter: ['variants.price.centAmount:100', 'variants.attributes.foo:bar']
        staged: true
        limit: 100
        offset: 2

      expect(query).toBe 'filter=variants.price.centAmount:100&filter=variants.attributes.foo:bar&staged=true&limit=100&offset=2'

    it 'should return empty string if object is not defined', ->
      expect(_m.stringifyQuery()).toBe ''
      expect(_m.stringifyQuery({})).toBe ''

  describe '_m :: parseQuery', ->

    it 'should parse object from string (with encoded param)', ->
      params = _m.parseQuery 'where=name(en%20%3D%20%22Foo%22)&staged=true&limit=100&offset=2'
      expect(params).toEqual
        where: encodeURIComponent('name(en = "Foo")')
        staged: 'true'
        limit: '100'
        offset: '2'

    it 'should parse object from string (with no encoded param)', ->
      params = _m.parseQuery 'where=not (name = "Peter" and age < 42)&staged=true&limit=100&offset=2'
      expect(params).toEqual
        where: 'not (name = "Peter" and age < 42)'
        staged: 'true'
        limit: '100'
        offset: '2'

    it 'should parse object from string with multiple same params (unique)', ->
      params = _m.parseQuery 'filter=variants.price.centAmount:100&filter=variants.attributes.foo:bar&staged=true&limit=100&offset=2'
      expect(params).toEqual
        filter: 'variants.attributes.foo:bar'
        staged: 'true'
        limit: '100'
        offset: '2'

    it 'should parse object from string with multiple same params (not unique)', ->
      params = _m.parseQuery 'filter=variants.price.centAmount:100&filter=variants.attributes.foo:bar&staged=true&limit=100&offset=2'
      , false
      expect(params).toEqual
        filter: ['variants.price.centAmount:100', 'variants.attributes.foo:bar']
        staged: 'true'
        limit: '100'
        offset: '2'

    it 'should return empty object if string is not defined', ->
      expect(_m.parseQuery()).toEqual {}
      expect(_m.parseQuery('')).toEqual {}

  describe '_m :: batchList', ->

    it 'should return batched list', ->
      batched = _m.batchList [1, 2, 3, 4, 5, 6, 7, 8, 9, 0], 3
      expect(batched).toEqual [[1, 2, 3], [4, 5, 6], [7, 8, 9], [0]]

    it 'should return batched list for big data (no memory leak)', ->
      batched = _m.batchList _.map([1..130000], (i) => {id: i}), 30
      expected(_.size(batched)).toBe(Math.ceil(130000 / 30))

    it 'should throw if size is not defined', ->
      expect(-> _m.batchList([])).toThrow new Error 'List batch size is required'
