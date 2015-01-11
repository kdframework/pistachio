{ VIEW_REGEX, DATA_REGEX } = require './pistachios-regex'

###*
 * Checks if given pistachio expression is a view expression.
 *
 * @param {String} expression - Pistachio expression
 * @return {Boolean}
###
isView = (expression) -> VIEW_REGEX.test expression

###*
 * Checks if given pistachio expression is a data expression.
 *
 * @param {String} expression - Pistachio expression
 * @return {Boolean}
###
isData = (expression) -> DATA_REGEX.test expression

###*
 * Sanitizes the template, removes unnecessary whitespace
 * trims out the `\n` statements from triple quote string
 * definition of `coffee-script`.
 *
 * @param {String} template - Unsanitized template
 * @return {String} Sanitized template
###
sanitizeTemplate = (template) ->

  return template
    .split '\n'
    .map (line) -> line.trim()
    .join ''

###*
 * Maps `htmlparser` representation of dom node
 * attributes to `KDViewNode#options` object definition.
 *
 * @param {Object} node - `htmlparser` representation of dom node
 * @return {Object} options - `KDViewNode` representation of dom node options
###
getOptionsForTreeNode = (node) ->

  tagName    = node.name
  attributes = {}
  cssClass   = null
  domId      = null

  for own key, value of node.attribs

    continue  unless value

    switch key
      when 'id'    then domId = value
      when 'class' then cssClass = value
      else attributes[key] = value

  attributes = null  unless Object.keys(attributes).length

  options            = {}
  options.tagName    = tagName
  options.domId      = domId  if domId
  options.cssClass   = cssClass  if cssClass
  options.attributes = attributes  if attributes

  return options


module.exports = {
  isView
  isData
  sanitizeTemplate
  getOptionsForTreeNode
}

