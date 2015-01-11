KDView = require 'kdf-view'

class FooView extends KDView

  constructor: (options = {}, data) ->

    super options, data

    @barView = new KDView { pistachio: "<div>BAR!</div>" }


  pistachio: ->
    """
    <section class="foo">
      {{> @barView}}
    </section>
    """


