htmlparser = require 'htmlparser2'

{ getOptionsForTreeNode, isView } = require './helpers'
{ SPLITTER_REGEX, regularPistachios,
  normalizedPistachios } = require './pistachios-regex'

###* @type {String} ###
DOM_ELEMENT_TYPE = 'tag'

###* @type {String} ###
DOM_TEXT_TYPE = 'text'

###* @type {String} ###
DOM_PISTACHIO_TYPE = 'pistachio'

module.exports = class Parser

  ###* @type {Object} ###
  @nodeType = {}

  ###* @type {number} ###
  @nodeType.VIEW_NODE = 1

  ###* @type {number} ###
  @nodeType.TEXT_NODE = 2

  ###* @type {number} ###
  @nodeType.PISTACHIO_NODE = 3

  ###*
   * Parses the given normalized tree and returns object representation.
   *
   * @param {String} template - Normalized `Pistachio` template.
   * @return {Array.<Object>} Parsed template
  ###
  @parse = (template) ->

    tree = Parser.parseTemplate template

    parsedElements = []

    for element in tree

      parsed = Parser.parseElement element
      parsedElements = parsedElements.concat parsed

    return parsedElements


  ###*
   * Parses the element and returns JS objects.
   * it uses `fb55/htmlparser2` to parse initial dom.
   * Doesn't deal with `Pistachio` itself.
   *
   * @param {String} template - Pistachio template string
   * @return {Array.<Object>} Object representation of template
  ###
  @parseTemplate: (template) -> tree = htmlparser.parseDOM template


  ###*
   * Parses single element. It takes over the job from `htmlparser`
   * and turns `text` nodes into smaller parts if there are some
   * pistachios exist inside of it and parses those elements.
   *
   * @param {Object} element - `htmlparser` representation of a dom element.
   * @param {Boolean=} [makeArray=yes] - Flag to determine if element should be wrapped with array.
  ###
  @parseElement: (element, makeArray = yes) ->

    # if the element is an array, run parse element for each item.
    Parser.parseElement child  for child in element  if Array.isArray element

    node = null

    # if element's type is a dom element type
    # compile it to a `KDViewNode` for itself first
    # and then start compiling the children of the node.
    if element.type is DOM_ELEMENT_TYPE

      node = createViewNode element
      node.children = []

      for child in element.children

        parsed = Parser.parseElement child, no

        if Array.isArray parsed
        then node.children = node.children.concat parsed
        else node.children.push parsed

    # if element's type is a dom text element type
    # first check to see if there are pistachio tokens in
    # it, and split the string at the indices where
    # pistachio tokens exist. After splitting map them
    # back to a `htmlparser` like representation and define
    # a new type for `pistachio` tokens.
    #
    # tl;dr: pistachio token extraction operation is happening here.
    else if element.type is DOM_TEXT_TYPE

      # if there are pistachios start
      # extraction of the pistachio/text elements.
      if hasPistachios element.data
        parts = element.data
          .split SPLITTER_REGEX     # split it with including pistachios.
          .map (str) -> str.trim()  # trim everything to be able to get rid of whitespace.
          .filter Boolean           # filter falsy values.
          .map transformBack        # Transform that back to parseable nodes.
          .map (part) -> Parser.parseElement part, no # parse them.

        return parts

      # if there are no pistachio tokens in this text node
      # create the regular text node, we are wrapping the value
      # with single quotes because of the fact that it's a string.
      else
        node = createTextNode "'#{element.data}'"

    # if element's type is pistachio type
    # determine if it's a view statement or just a
    # regular `coffeescript/javascript` expression and delegate
    # to necessary method.
    else if element.type is DOM_PISTACHIO_TYPE

      viewPresent = no

      node = element.data.replace normalizedPistachios, (_, expression) ->

        viewPresent = isView expression
        expression = expression.substr(1)  if viewPresent

        return expression.trim()

      if viewPresent
        node = createPistachioNode node
      else
        # we are not wrapping it with quotes because
        # it's an expression rather than a string.
        node = createTextNode node

    return if makeArray then [node] else node


###*
 * Create a parseable text node.
 *
 * @param {String} value - value of text node
 * @return {Object} Parseable text node object
 * @api private
###
createTextNode = (value) ->

  textNode =
    type: Parser.nodeType.TEXT_NODE
    options: { value }


###*
 * Create a parseable pistachio node.
 *
 * @param {String} value - Value of pistachio node
 * @return {Object} Parseable pistachio node object
 * @api private
###
createPistachioNode = (value) ->

  pistachioNode =
    type: Parser.nodeType.PISTACHIO_NODE
    options: { value }


###*
 * Create a parseable view node.
 *
 * @param {Object} element - `htmlparser` tree element
 * @return {Object} Parseable view node object
 * @api private
###
createViewNode = (element) ->

  options = getOptionsForTreeNode element

  viewNode =
    type     : Parser.nodeType.VIEW_NODE
    options  : options
    children : []


###*
 * Transform string into either a pistachio
 * dom node or text dom node.
 *
 * @param {String} part - part to be transformed back to `htmlparser` like node.
 * @param {Object}
 * @api private
###
transformBack = (data) ->

  transformedPart = { data }
  transformedPart.type = if hasPistachios data
  then DOM_PISTACHIO_TYPE
  else DOM_TEXT_TYPE

  return transformedPart


###*
 * Checks given string has pistachio tokes in it.
 *
 * @param {String} value - Text to see if it contains pistachio
 * @return {Boolean}
 * @api private
###
hasPistachios = (value) -> /({{\s?(?:[^}]*)\s?}})/.test value

