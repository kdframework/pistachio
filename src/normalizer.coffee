h      = require 'hyperscript'
coffee = require 'coffee-script'

{ isView, isData, sanitizeTemplate } = require './helpers'
{ regularPistachios, DATA_REGEX } = require './pistachios-regex'

module.exports = class Normalizer

  ###*
   * Normalizes given pistachio template.
   * - Compiles `coffee-script` expressions to `javascript`.
   * - Compiles attributed pistachio tokens to dom-wrapped unattributed tokens.
   *
   * h3 Example
   *
   *     Normalizer.normalize '{span#id.class{> @view}}'
   *     # => '<span class="class" id="id">{{> this.view}}</span>'
   *
   * @param {String} template - Pistachio template
   * @return {String} Normalized version of template.
   * @todo Implement custom attributes for attributed pistachio.
  ###
  @normalize: (template) ->

    template = sanitizeTemplate template

    # look for pistachio strings if present start normalization.
    template = template.replace regularPistachios, (_, markup = '', expression)->

      viewPresent = isView expression
      dataPresent = isData expression

      # if view present normalize it.
      if viewPresent
        expression = Normalizer.normalizeView expression

      # if data present normalize it.
      else if dataPresent
        expression = Normalizer.normalizeData expression

      # compile coffee-script into javascript.
      expression = coffeeCompile expression

      # add view identifier `>` back to expression if view present.
      expression = "{{#{if viewPresent then '> ' else ''}#{expression}}}"

      # apply markup if it's attrited.
      expression = Normalizer.normalizeWithMarkup markup, expression  if markup

      return expression

    return template


  ###*
   * Normalizes Pistachio view expression.
   *
   * h3 Example
   *
   *     Normalizer.normalizeView '> @view'
   *     # => '@view'
   *
   * @param {String} expression - View expression before normalization
   * @return {String} Normalized version of expression
  ###
  @normalizeView: (expression) -> expression.substr(1).trim()


  ###*
   * Normalizes Pistachio data expressions.
   *
   * h3 Example
   *
   *     Normalizer.normalizeData '#(foo)'
   *     # => '@data.foo'
   *
   * @param {String} expression - Data expression before normalization
   * @return {String} Normalized version of exression
  ###
  @normalizeData: (expression) -> expression.replace DATA_REGEX, (_, expr) -> "@data.#{expr}"


  ###*
   * Normalizes Pistachio attributed expression.
   *
   * h3 Example
   *
   *     Normalizer.normalizeData '#(foo)'
   *     # => '@data.foo'
   *
   * @param {String} markup - attributes of the expression
   * @param {String} expression - Normalized pistachio expression
   * @return {String} Expression after wrapping it with a DOM element
  ###
  @normalizeWithMarkup: (markup, expression) ->

    element = h(markup, expression).outerHTML
    element = element.replace /&gt;/g, '>'


coffeeCompile = (expression) ->

  expression = try coffee.compile(expression.replace(/\\"/g, "\""), bare: yes).replace /"/g, '\\"'
  catch e then console.error e; expression

  if expression.match(/;/g)?.length > 1
  then throw new SyntaxError 'Only one expression is allowed.'
  else expression = expression.replace(/\n|;/g, '')

  return expression


