express = require("express")
router = express.Router()

Planet = require '../models/planet'

# GET home page.
router.get "/", (req, res) ->
  res.render "index",
    title: "planetary"

router.get "/planet", (req, res) ->
  console.log 'Making planet...'
  planet = new Planet()
  planet.flipRandomEdges(2)
  res.json planet.asJSONGeometry()
  console.log '...done'

module.exports = router
