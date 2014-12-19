THREE = require 'three'
_ = require 'lodash'
require('../lib/SubdivisionModifier')(THREE)
geom2json = require '../lib/geom2json'

assert = require 'assert'

PLANET_DEFAULTS =
  detail: 2

# Take plain (unweighted) average of a set of points.
averagePoints = (pts) -> averageWeightedPoints pts.map (pt) -> [pt, 1]

# Take a weighted average of a set of points.
averageWeightedPoints = (pts...) ->

  # If we passed in a single array, we're not taking advantage of the splat.
  if pts.length is 1 then pts = pts[0]

  # Sum the points and their weights.
  avg = pts.reduce (_a, _b) ->
    [a, b] = [_a[0], _b[0]]
    [
      new THREE.Vector3(
        a.x + b.x*_b[1],
        a.y + b.y*_b[1],
        a.z + b.z*_b[1]
      ),
      _a[1] + b[1]
    ]
  , [new THREE.Vector3(0,0,0), 0]

  # Divide the average by the cumulative weights.
  avg[0].setX avg.x/avg[1]
  avg[0].setY avg.y/avg[1]
  avg[0].setZ avg.z/avg[1]
  avg[0]

module.exports =
class Planet

  constructor: (@opt={}) ->
    @opt = _.defaults @opt, PLANET_DEFAULTS

    # Everything is computed on a sphere of radius 1.
    @geom = new THREE.IcosahedronGeometry 4, 0

    modifier = new THREE.SubdivisionModifier( @opt.detail )
    modifier.modify @geom

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

    # Pick a second face neighboring the first (i.e. sharing 2 verts)
    tri2 = _.sample @geom.faces.filter (face) ->
      _.intersection(tri1Idxs, [face.a, face.b, face.c]).length is 2
    tri2Idxs = [tri2.a, tri2.b, tri2.c]

    # Pick a point from our second triangle that's
    # 1. also in our first triangle, and
    # 2. isn't the first point we picked.
    #
    # There should be exactly one point that meets these criteria.
    v2SampleSpace = tri2Idxs.filter((v) -> (v in tri1Idxs) and (v isnt v1))
    v2 = _.sample v2SampleSpace

    # x1 and x2 are the non-shared verts in tri1 and tri2, respectively.
    x1 = tri1Idxs.filter((v) -> v not in [v1, v2])[0]
    x2 = tri2Idxs.filter((v) -> v not in [v1, v2])[0]

    # Perform the flip.
    [tri1.a, tri1.b, tri1.c] = [x1, v1, x2]
    [tri2.a, tri2.b, tri2.c] = [x1, v2, x2]


    try
      assert _.all tri1.a, tri1.b, tri1.c
      assert _.all tri2.a, tri2.b, tri2.c
    catch e
      console.log "tri1", tri1
      console.log "tri2", tri2
      console.log "v1", v1
      console.log "tri2Idxs", tri2Idxs
      console.log "v2 sample space", v2SampleSpace
      throw e

  flipRandomEdges: (n) -> [0...n].forEach => @flipRandomEdge()

  # Relax the mesh by
  relax: (opt={}) ->

    {t} = opt

    t ?= 1

    # Get a copy of our original vert locations so we can refer to it even after we've started modifying.
    oldVerts = _.cloneDeep @geom.vertices

    # Function to get all vertices that share an edge with the given vert.
    # Since all our faces are initially triangles, we can do this
    # by getting all vertices that share a face with the given vert.
    getNeighbors = (v) =>
      _.uniq(
        @geom.faces.filter (f) -> v in [f.a, f.b, f.c]
      ).filter (v2) -> v isnt v2
      .map (i) -> oldVerts[i]

    @geom.vertices = @geom.vertices.map (vert, i) ->

      # Fetch the neighbors for the vert we're working on.
      neighbors = getNeighbors i

      # Compute the average location of the neighbors.
      avg = averagePoints neighbors

      # Compute the relaxed point by blending between the old position and the new one.
      # If you have a negative `t`, then I suppose this would make your mesh stressed out? o_0
      relaxed = averageWeightedPoints [avg, t], [vert, 1-t]

      # We've probably budged the point off the unit sphere; this step fixes that.
      relaxed.normalize()


  asJSONGeometry: -> geom2json @geom
