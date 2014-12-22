Normalizer = require './normalizer'
Parser     = require './parser'
Compiler   = require './compiler'

util = require 'util'

module.exports = class Pistachio

  @compile = (pistachio) ->

    normalized = Normalizer.normalize pistachio
    parsed     = Parser.parse normalized
    compiled   = Compiler.compile parsed

    return compiled


