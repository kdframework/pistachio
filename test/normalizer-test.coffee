jest.autoMockOff()

Normalizer = require '../src/normalizer'

describe 'Normalizer', ->

  describe '.normalize', ->

    it 'normalizes pistachio view string', ->

      pistachio = "{{> @view}}"
      normalized = Normalizer.normalize pistachio

      expected = "{{> this.view}}"

      expect(normalized).toBe expected


    it 'normalizes pistachio data string', ->

      normalized = Normalizer.normalize "{{ #(foo)}}"
      expect(normalized).toBe "{{this.data.foo}}"


    it 'normalizes coffeescript expressions', ->

      normalized = Normalizer.normalize "{{ dummyFunctionCall #(foo)}}"
      expect(normalized).toBe "{{dummyFunctionCall(this.data.foo)}}"

      normalized = Normalizer.normalize "{{ @instanceMethod #(foo) }}"
      expect(normalized).toBe "{{this.instanceMethod(this.data.foo)}}"


    it 'normalizes pistachio view string with attributes', ->

      pistachio = "{span#id.class{> @view}}"

      normalized = Normalizer.normalize pistachio

      expected = '<span class="class" id="id">{{> this.view}}</span>'

      expect(normalized).toBe expected


    it 'normalizes complex pistachios', ->

      pistachio =\
        """
        <div class="activity-content-wrapper">
          {article#dom-id.foo-bar.baz{> @settingsButton}}
          {{> @avatar}}
          <div class='meta'>
            {{> @author}}
            {{> @timeAgoView}} <span class="location hidden"> from San Francisco</span>
          </div>
          {{> @editWidgetWrapper}}
          {article.has-markdown{KD.utils.formatContent #(body)}}
          {{> @resend}}
          {{> @embedBox}}
          {{> @actionLinks}}
          {{> @likeSummaryView}}
        </div>
        {{> @commentBox}}
        """

      expected = [
        '<div class="activity-content-wrapper">'
          '<article class="foo-bar baz" id="dom-id">{{> this.settingsButton}}</article>'
          "{{> this.avatar}}"
          "<div class='meta'>"
            "{{> this.author}}"
            '{{> this.timeAgoView}} <span class="location hidden"> from San Francisco</span>'
          "</div>"
          "{{> this.editWidgetWrapper}}"
          '<article class="has-markdown">{{KD.utils.formatContent(this.data.body)}}</article>'
          "{{> this.resend}}"
          "{{> this.embedBox}}"
          "{{> this.actionLinks}}"
          "{{> this.likeSummaryView}}"
        "</div>"
        "{{> this.commentBox}}"
      ].join ''

      normalized = Normalizer.normalize pistachio

      expect(normalized).toBe expected

  describe '.normalizeWithMarkup', ->

    { normalizeWithMarkup } = Normalizer

    it 'wraps expression with a dom element with id and class', ->

      markup = 'span#id.class'
      expression = '{{> this.view}}'

      normalized = normalizeWithMarkup markup, expression

      expect(normalized).toBe '<span class="class" id="id">{{> this.view}}</span>'


    xit 'it supports data attributes', ->

      markup = 'span[foo=data]'
      expression = '{{> this.view}}'

      normalized = normalizeWithMarkup markup, expression

      expect(normalized).toBe '<span foo="data">{{> this.view}}</span>'


  describe '.normalizeView', ->

    { normalizeView } = Normalizer

    it 'normalizes view statements', ->

      expression = normalizeView '> @view'
      expect(expression).toBe '@view'


  describe '.normalizeData', ->

    { normalizeData } = Normalizer

    it 'normalizes data expressions', ->

      expression = normalizeData '#(foo)'
      expect(expression).toBe '@data.foo'


