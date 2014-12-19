THREE = require 'three'
_ = require 'lodash'
require('../lib/SubdivisionModifier')(THREE)
geom2json = require '../lib/geom2json'

PLANET_DEFAULTS =
  detail: 2

module.exports =
class Planet
  constructor: (@opt={}) ->
    @opt = _.defaults @opt, PLANET_DEFAULTS
    @geom = new THREE.IcosahedronGeometry 4, 0
    modifier = new THREE.SubdivisionModifier( @opt.detail )
    modifier.modify @geom
    console.log @geom

  # # Utility functions

  # Flip a random edge in the sphere.
  flipRandomEdge: ->

    # Choose a random triangle.
    tri1 = _.sample @geom.faces
    tri1Idxs = [tri1.a, tri1.b, tri1.c]

    # Select a random point from that face.
    v1 = _.sample tri1Idxs

    # Create a list of the points we didn't chose.
    tri1IdxDrop = tri1Idxs.filter (i) -> i isnt v1

    # Pick a second face neighboring the first.
    tri2 = _.sample @geom.faces.filter (face) ->
      v1 in [face.a, face.b, face.c]
    tri2Idxs = [tri2.a, tri2.b, tri2.c]

    # Pick a point from our second triangle that's
    # 1. also in our first triangle, and
    # 2. isn't the first point we picked.
    #
    # There should only be one point that meets these criteria.
    v2 = tri2Idxs.filter((v) -> (v in tri1Idxs) and (v isnt v1))[0]

    # x1 and x2 are the non-shared verts in tri1 and tri2, respectively.
    x1 = tri1Idxs.filter((v) -> v not in [v1, v2])[0]
    x2 = tri2Idxs.filter((v) -> v not in [v1, v2])[0]

    # Perform the flip.
    [tri1.a, tri1.b, tri1.c] = [x1, v1, x2]
    [tri2.a, tri2.b, tri2.c] = [x1, v2, x2]

  flipRandomEdges: (n) -> [0...n].forEach => @flipRandomEdge()
  
  asJSONGeometry: -> geom2json @geom
