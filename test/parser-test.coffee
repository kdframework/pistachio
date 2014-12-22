jest.autoMockOff()
jest.dontMock 'htmlparser2'

util = require 'util'

Parser = require '../src/parser'
Normalizer = require '../src/normalizer'

describe 'Parser', ->

  describe '.parse', ->

    it 'parses template with pistachio in it', ->

      pistachio = Normalizer.normalize \
        """
        <div class='meta'>
          {{> @timeAgoView}} <span class="location hidden"> from San Francisco</span>
        </div>
        {{> @editWidgetWrapper}}
        """

      parsed = Parser.parse pistachio

      expect(parsed).toEqual [
        {
          type: 1
          options: { tagName: 'div', cssClass: 'meta' }
          children: [
            {
              type: 3
              options: { value: 'this.timeAgoView' }
            }
            {
              type: 1
              options: { tagName: 'span', cssClass: 'location hidden' }

              children: [ { type: 2, options: { value: "' from San Francisco'" } } ]
            }
          ]
        }
        {
          type: 3
          options: { value: 'this.editWidgetWrapper' }
        }
      ]


  describe '.parseElement', ->

    { parseElement } = Parser

    it 'parses given `htmlparser` dom tree/element', ->

      tree   = Parser.parseTemplate "<div></div>"
      parsed = parseElement tree[0]

      expect(parsed).toEqual [{ type: 1, children: [], options: { tagName: 'div' } }]


    it 'parses given `htmlparser` text node', ->

      tree = Parser.parseTemplate 'foo bar'
      parsed = parseElement tree[0]

      expect(parsed).toEqual [{ type: 2, options: { value: "'foo bar'" } }]


    it 'parses view pistachio', ->

      tree = Parser.parseTemplate "{{> this.view}}"
      parsed = parseElement tree[0]

      expect(parsed).toEqual [{ type: 3, options: { value: 'this.view' } }]


    it 'parses regular pistachio', ->

      pistachio = "{{ this.data.foo }}"

      tree = Parser.parseTemplate pistachio
      parsed = parseElement tree[0]

      expect(parsed).toEqual [ { type: 2, options: { value: 'this.data.foo' } } ]

      pistachio = "{{ this.data.foo}}{{ dummyFunctionCall(bar)}}"

      tree = Parser.parseTemplate pistachio
      parsed = parseElement tree[0]

      expect(parsed).toEqual [
          type: 2, options: {value: 'this.data.foo'}
        ,
          type: 2, options: {value: 'dummyFunctionCall(bar)'}
        ]


    it 'parses complex pistachio', ->

      pistachio =
        """
        <div class="activity-content-wrapper">
          {article#dom-id.foo-bar.qux{> @settingsButton}}
          {{> @avatar}}
          <div class='meta'>
            {{> @timeAgoView}} <span class="location hidden"> from San Francisco</span>
          </div>
          {{> @editWidgetWrapper}}
          {article.has-markdown{KD.utils.formatContent #(body)}}
        </div>
        {{> @commentBox}}
        """

      tree = Parser.parseTemplate Normalizer.normalize pistachio
      parsed = parseElement tree[0]

      expected = [{
        type: 1
        options: { tagName: 'div', cssClass: 'activity-content-wrapper' }
        children: [{
          type: 1
          options: { tagName: 'article', domId: 'dom-id', cssClass: 'foo-bar qux' }
          children: [{
            type: 3
            options: { value: 'this.settingsButton' }
          }]
        },
        {
          type: 3
          options: { value: 'this.avatar' }
        },
        {
          type: 1
          options: { tagName: 'div', cssClass: 'meta' }
          children: [{
            type: 3
            options: { value: 'this.timeAgoView' }
          }
          {
            type: 1,
            options: { tagName: 'span', cssClass: 'location hidden' },
            children: [{
              type: 2,
              options: { value: "' from San Francisco'" }
            }]
          }]
        },
        {
          type: 3
          options: { value: 'this.editWidgetWrapper' }
        },
        {
          type: 1
          options: { tagName: 'article', cssClass: 'has-markdown' }
          children: [{
            type: 2
            options: { value: 'KD.utils.formatContent(this.data.body)' }
          }]
        }]
      }]

      expect(parsed).toEqual expected

      parsed = parseElement tree[1]

      expected = [ { type: 3, options: { value: 'this.commentBox' } } ]

log = (args...)-> console.log util.inspect args..., no, null

