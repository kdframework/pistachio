{ KDViewNode, KDTextNode } = require 'kdf-dom'

module.exports = class PistachioMixin

  constructor: (options = {}, data) ->

    @subviews = @extractSubviews(options.pistachio) or @subviews


  extractSubviews: (pistachio) ->

    pistachio = @options.pistachio or @pistachio
    pistachio = pistachio.call this  if 'function' is typeof pistachio

    return pistachio

