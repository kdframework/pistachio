jest.autoMockOff()

htmlparser = require 'htmlparser2'

fs = require 'fs'

Pistachio = require '../src/pistachio'

describe 'Pistachio', ->

  describe '.compile', ->

    it 'compiles', ->

      pistachio =\
        """
        <div class="activity-content-wrapper">
          {{> @settingsButton}}
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

      compiled = Pistachio.compile pistachio

      expected = "[new KDViewNode({tagName: 'div',cssClass: 'activity-content-wrapper',subviews: [this.settingsButton,this.avatar,new KDViewNode({tagName: 'div',cssClass: 'meta',subviews: [this.author,this.timeAgoView,new KDViewNode({tagName: 'span',cssClass: 'location hidden',subviews: [new KDTextNode({value:' from San Francisco'})]})]}),this.editWidgetWrapper,new KDViewNode({tagName: 'article',cssClass: 'has-markdown',subviews: [new KDTextNode({value:KD.utils.formatContent(this.data.body)})]}),this.resend,this.embedBox,this.actionLinks,this.likeSummaryView]}),this.commentBox]"

      expect(compiled).toBe expected

  describe '.compile', ->

    it 'compiles regular subview pistachio', ->

      pistachio = "{{> @foo}}"
      compiled  = Pistachio.compile pistachio

      expected = '[this.foo]'

      expect(compiled).toBe expected


    it 'compiles regular data pistachio', ->

      pistachio = "{{ #(foo) }}"
      compiled = Pistachio.compile pistachio

      expected = '[new KDTextNode({value:this.data.foo})]'

      expect(compiled).toBe expected


    xit 'compiles attributed view pistachio', ->

      pistachio = "{span#foo.bar.baz[data-id=qux]{> @view}}"
      compiled  = Pistachio.compile pistachio

      expected = [
        "v = new KDViewNode({"
          "tagName: 'span',"
          "domId: 'bar',"
          "cssClass: 'bar baz',"
          "attributes: { 'data-id': 'qux' },"
          "subviews: [this.view]}"
        "});"
      ].join ' '

      expect(compiled).toBe expected


  describe '.compileFile', ->

    it 'compiles given file', ->

      testFile = fs.readFileSync("#{__dirname}/fixtures/test.js").toString 'utf8'
      expected = fs.readFileSync("#{__dirname}/fixtures/compiled.js").toString 'utf8'

      compiled = Pistachio.compileFile(testFile).toString 'utf8'

      expect(compiled).toBe expected



