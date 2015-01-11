{ nodeType } = require './parser'

module.exports = class Compiler

  ###*
   * Compiles parsed text node.
   *
   * @param {Object} node - node to be compiled.
   * @return {String}
  ###
  @compileTextNode = (node) -> "new KDTextNode({value:#{node.options.value}})"


  ###*
   * Compiles parsed text node.
   *
   * @param {Object} node - node to be compiled.
   * @return {String}
  ###
  @compilePistachioNode = (node) -> node.options.value


  ###*
   * Compiles parsed view node. After finish, it starts
   * compiling the node's children.
   *
   * @param {Object} node - node to be compiled.
   * @return {String}
  ###
  @compileViewNode = (node) ->

    { tagName, cssClass, attributes, domId } = node.options
    { children } = node

    compiled = []

    compiled.push "new KDViewNode({"
    compiled.push "tagName: '#{tagName}',"  if tagName?
    compiled.push "domId: '#{domId}',"  if domId?
    compiled.push "cssClass: '#{cssClass}',"  if cssClass?
    compiled.push "attributes: #{JSON.stringify attributes},"  if attributes?
    compiled.push "subviews: [#{children.map(@compileNode.bind this).join ','}]"
    compiled.push "})"

    return compiled.join ''


  ###*
   * Delegates to individual node compilation methods
   * depending on the type property of the node.
   *
   * @param {Object} node - Parsed dom element.
   * @return {String} Compiled string of given node.
  ###
  @compileNode = (node) ->

    return switch node.type
      when nodeType.VIEW_NODE      then @compileViewNode node
      when nodeType.TEXT_NODE      then @compileTextNode node
      when nodeType.PISTACHIO_NODE then @compilePistachioNode node
      else throw new Error 'Node type is unknown'


  ###*
   * Compiles given parsed tree.
   *
   * h3 Example
   *
   *     Compiler.compile [{type: nodeType.PISTACHIO_NODE, options: { value: 'this.view' }]
   *     # => ['this.view']
   *
   * @param {Array} parsed - Parsed tree of pistachio template.
   * @return {String} Compiled string of given node tree.
  ###
  @compile = (parsed) -> "[#{parsed.map(@compileNode.bind this).join ','}]"


