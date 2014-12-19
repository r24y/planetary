{assert} = require 'chai'

_ = require 'lodash'

Planet = require '../models/planet'

describe "Planet", ->

  beforeEach ->
    @planet = new Planet()

  it "should be a planet", ->
    assert.ok(@planet)

  it "should have #{4*4*20} faces", ->
    assert.equal @planet.geom.faces.length, 4*4*20

  it "should flip an edge and be ok", ->
    {faces, vertices} = @planet.geom
    @planet.flipRandomEdge()
    assert.equal @planet.geom.faces, faces, 'should not gain or lose faces'
    assert.equal @planet.geom.vertices, vertices, 'should not gain or lose vertices'

  it "should flip a bunch of edges and be ok", ->
    {faces, vertices} = @planet.geom
    [0..100].forEach => @planet.flipRandomEdge()
    assert.equal @planet.geom.faces, faces, 'should not gain or lose faces'
    assert.equal @planet.geom.vertices, vertices, 'should not gain or lose vertices'
