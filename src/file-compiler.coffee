falafel = require 'falafel'

Normalizer = require './normalizer'
Parser     = require './parser'
Compiler   = require './compiler'

compilePistachio = (pistachio) -> Compiler.compile Parser.parse Normalizer.normalize pistachio

###*
 * @class Pistachio.FileCompiler
 *
 * It gets a js file and compiles the pistachio
 * templates into function calls.
###
module.exports = class FileCompiler

  ###*
   * Gets the source and scans the AST with falafel.
   * extracts the properties, members and methods named with
   * given magic word, and compiles them.
   *
   * @param {String} src - JS source file.
   * @param {String} magicWord - Identifier to extract pistachio templates from.
   * @return {String} Same input source file with pistachio strings compiled.
  ###
  @compile = (src, magicWord = 'pistachio') ->

    output = falafel src, (node) ->

      switch
        when isMagicProperty node, magicWord   then FileCompiler.compileProperty node
        when isMagicMember node, magicWord     then FileCompiler.compileMember node
        when isMagicIdentifier node, magicWord then FileCompiler.compileIdentifier node

    return output


  ###*
   * Compile property nodes.
   *
   * @param {Object} node - Property assignment node.
   * @see `node-falafel`
  ###
  @compileProperty: (node) ->

    { value } = node.value

    compiled = "#{node.key.name}: #{compilePistachio value}"

    node.update compiled


  ###*
   * Compile member nodes. Such as protoype assignments.
   * Compile the body if member is a function expression.
   *
   * @param {Object} node - Member assignment node.
   * @see `node-falafel`
  ###
  @compileMember: (node) ->

    if node.right.type is 'FunctionExpression'

      { body } = node.right

      for statement in body.body

        if statement.type is 'ReturnStatement'

          { value } = statement.argument
          compiled = compilePistachio value

          statement.argument.update compiled

    else if node.right.type is 'Literal'

      { value } = node.right

      compiled = compilePistachio value

      node.right.update compiled


  ###*
   * TODO: NOT IMPLEMENTED YET.
   * It doesn't to anything.
  ###
  @compileIdentifier: (node) ->

    console.log 'compileIdentifier', node.source()


isMagicProperty = (node, magicWord) ->
  node.type is 'Property' and node.key.name is magicWord

isMagicMember = (node, magicWord) ->
  node.type is 'AssignmentExpression' and\
  node.left.type is 'MemberExpression' and\
  node.left.property.name is magicWord

isMagicIdentifier = (node, magicWord) ->
  node.type is 'AssignmentExpression' and\
  node.left.type is 'Identifier' and\
  node.left.name is magicWord


