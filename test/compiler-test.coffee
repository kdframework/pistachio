jest.autoMockOff()

Compiler = require '../src/compiler'

describe 'Compiler', ->

  describe '.compileTextNode', ->

    it 'compiles text node', ->

      textNode = { type: 2, options: { value: "'foo bar'" } }
      compiled = Compiler.compileTextNode textNode

      expect(compiled).toBe "new KDTextNode({value:'foo bar'})"

  describe '.compilePistachioNode', ->

    it 'compiles pistachio node', ->

      pistachioNode = { type: 3, options: { value: 'this.view' } }
      compiled = Compiler.compilePistachioNode pistachioNode

      expect(compiled).toBe 'this.view'

  describe '.compileViewNode', ->

    it 'compiles view node', ->

      viewNode = { type: 1, options: { tagName: 'div', cssClass: 'foo' }, children: [] }
      compiled = Compiler.compileViewNode viewNode

      expect(compiled).toBe "new KDViewNode({tagName: 'div',cssClass: 'foo',subviews: []})"


    it 'compiles view node with children', ->

      viewNode =
        type: 1
        options: { tagName: 'div', domId: 'foo' }
        children: [ { type: 3, options: { value: 'this.view' } } ]

      expected =\
        "new KDViewNode({tagName: 'div',domId: 'foo',subviews: [this.view]})"

      compiled = Compiler.compileViewNode viewNode

      expect(compiled).toBe expected


  describe '.compileNode', ->

    it 'delegates to necessary function', ->

      spyOn Compiler, 'compileViewNode'
      spyOn Compiler, 'compileTextNode'
      spyOn Compiler, 'compilePistachioNode'

      Compiler.compileNode { type: 1 }
      Compiler.compileNode { type: 2 }
      Compiler.compileNode { type: 3 }

      expect(Compiler.compileViewNode).toHaveBeenCalledWith { type: 1 }
      expect(Compiler.compileTextNode).toHaveBeenCalledWith { type: 2 }
      expect(Compiler.compilePistachioNode).toHaveBeenCalledWith { type: 3 }


  describe '.compile', ->

    it 'compiles parsed template', ->

      parsed = [
        { type: 2, options: { value: "'partial'" } }
        { type: 3, options: { value: 'this.barView' } }
      ]

      compiled = Compiler.compile parsed
      expected = "[new KDTextNode({value:'partial'}),this.barView]"

      expect(compiled).toBe expected


