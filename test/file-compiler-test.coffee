jest.autoMockOff()

FileCompiler = require '../src/file-compiler'

fs = require 'fs'

describe 'FileCompiler', ->

  describe '.compile', ->

    it 'compiles given file', ->

      testFile = fs.readFileSync("#{__dirname}/fixtures/test.js").toString 'utf8'
      expected = fs.readFileSync("#{__dirname}/fixtures/compiled.js").toString 'utf8'

      compiled = FileCompiler.compile testFile

      expect(compiled.toString 'utf8').toBe expected


  describe '.compilePistachioOption', ->

    it 'compiles pistachios passed as strings', ->

      testFile = "new KDViewNode({pistachio:'{{> this.view}}'})"

      expected = "new KDViewNode({pistachio: [this.view]})"

      compiled = FileCompiler.compile testFile

      expect(compiled.toString 'utf8').toEqual expected


  describe '.compileMember', ->

    it 'compiles member expressions when it is function', ->

      testFile = """
        FooView.prototype.pistachio = function () {
          return '{{> @view}}'
        }
        """

      expected = """
        FooView.prototype.pistachio = function () {
          return [this.view]
        }
        """

      compiled = FileCompiler.compile testFile

      expect(compiled.toString 'utf8').toEqual expected


    it 'compiles more complex pistachio statements as methods', ->

      testFile = '''
        FooView.prototype.pistachio = function() {
          return '<section class="foo">{{> @barView}}</section>';
        };
        '''

      expected = '''
        FooView.prototype.pistachio = function() {
          return [new KDViewNode({tagName: 'section',cssClass: 'foo',subviews: [this.barView]})];
        };
        '''

      compiled = FileCompiler.compile testFile

      expect(compiled.toString 'utf8').toEqual expected


    it 'compiles member expression when they are just property assignment', ->

      testFile = """
        FooView.prototype.pistachio = '{{ #(foo)}}'
        """

      expected = """
        FooView.prototype.pistachio = [new KDTextNode({value:this.data.foo})]
        """

      compiled = FileCompiler.compile testFile

      expect(compiled.toString 'utf8').toEqual expected


