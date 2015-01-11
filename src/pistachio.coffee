Normalizer   = require './normalizer'
Parser       = require './parser'
Compiler     = require './compiler'
FileCompiler = require './file-compiler'

module.exports = class Pistachio

  ###*
   * Compiles given pistachio string.
   * It executes the compilation flow.
   *
   * @param {String} pistachio
   * @return {String} `KDViewNode` initialization fn calls.
  ###
  @compile = (pistachio) ->

    normalized = Normalizer.normalize pistachio
    parsed     = Parser.parse normalized
    compiled   = Compiler.compile parsed

    return compiled


  ###*
   * Compiles given file as string.
   *
   * @param {String} src - source JS file as UTF-8 String
   * @return {String} Source with compiled pistachios.
  ###
  @compileFile = (src, magicWord = 'pistachio') -> FileCompiler.compile src, magicWord


