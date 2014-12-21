This a part of the `KDFramework` that handles the compilation of templating operations.

## KDPistachio
This package exports both the definition of the `Pistachio` templating language and also provides the necessary tools to normalize, parse and compile the `Pistachio` templates.

Pistachio
=========
`Pistachio` is the templating language of `KDFramework`. It uses mustache syntax but rather than focusing on the logical expressions, it only tries to represent a dom structure of a component. Because of that there are no loops, no conditionals, etc.

There are mainly 2 parts of a `Pistachio` token: `{<markup>{<expression>}}`

- `markup`: Emmet-style definition of a wrapper which will wraps the result of the `Pistachio` expression in `DOM`. (e.g `span#dom-id.class-one.class-two`)

- `expression`: Any valid `coffee-script` expression is acceptable. There are 2 special expressions to make it easier to subviews and represent the values from the data object of the view.

    - *Subview* - `{{> <subview> }}` - Use `>` character right after the opening curly braces to represent a view instance.
    - *Data* - `{{ #(<property>) }}` - Use `#()` and pass the name of the property from object's data. Equivalent of `@data[<property>]`

```coffee
# {<markup>{<expression>}}
pistachio = "{span#foo.bar.baz{#(qux)}}"

# which represents a `KDViewNode` instance
view = new KDViewNode
  tagName  : 'span'
  domId    : 'foo'
  cssClass : 'bar baz'
  partial  : this.data.qux # new KDTextNode { value: this.data.qux }

# which will eventually be used to represent the following dom element
# => <span class="bar baz" id="foo">this.data.qux</span>
```

Tools
=====
Compilation of a `Pistachio` template includes 3 steps.

- Normalizing the initial template.
- Parsing the normalized template.
- Compiling the parsed template into function calls.

#### Step 1: `Normalizer`
This step includes operations to make template string easier to parse, Such as compiling `coffee-script` code into `JavaScript`, simplifying `Pistachio` expressions.

** Responsibilities of `Normalizer`

- Compiling `coffee-script` expressions into `JavaScript` expressions.
```coffee
{ Normalizer } = require 'kdf-pistachio'

template = "{{> @view}} {{ functionCall foo }}"
normalized = Normalizer.normalize template

console.log normalized
# => "{{> this.view}}{{functionCall(foo)}}"
```

- Transforming `Pistachio` expressions with markup into regular expressions with a `DOM` element wrapping it.
```coffee
{ Normalizer } = require 'kdf-pistachio'

template = "{article.has-markdown{> view}}"
normalized = Normalizer.normalize template

console.log normalized
# => '<article class="has-markdown">{{> view}}</article>'
```

- Transforming `Pistachio` `data property` expressions.
```coffee
{ Normalizer } = require 'kdf-pistachio'

template = "{{ #(foo)}}"
normalized = Normalizer.normalize template

console.log normalized
# => "{{ this.data.foo}}"
```

#### Step 2: `Parser`
`Parser` takes a normalized template string and turns that into regular JavaScript arrays that contains the object representation of each node in `Pistachio` template. It makes it easier to traverse over the tree and operate on it. For example, one other tool, `Compiler`, uses this parsed output and generates necessary `KDViewNode`/`KDTextNode` function calls.

```coffee
{ Parser } = require 'kdf-pistachio'

normalizedTemplate = 
  """
  <div class="foo">Hello World</div>
  {{> this.view}}
  """

parsed = Parser.parse normalizedTemplate
expect(parsed).toEqual [
  {
    type: Parser.nodeType.VIEW_NODE
    options: 
      tagName: 'div'
      cssClass: 'foo'
      children: [{type: Parser.nodeType.TEXT_NODE, options: { value: "'Hello World'" }}]
  }
,
  {
    type: Parser.nodeType.PISTACHIO_NODE
    options: {value: '{{> this.view}}'}
  }
]
```

#### Step 3: `Compiler`
`Compiler` takes parsed templated, and turns them into `KDViewNode`/`KDTextNode` object creation calls in `JavaScript`. So this is can be added into the build step after `coffee-script` to `JavaScript` compilation finished. 

So if we use the parsed output from last example:

```coffee
{ Compiler } = require 'kdf-pistachio'

compiled = Compiler.compile parsed # the result from last example.
###
compiled result:
[new KDViewNode({
  tagName: 'div'
  cssClass: 'foo'
  subviews: [
    new KDTextNode({value: 'Hello World'})
  ]
}), this.view]
###
```

#### Connecting them all together.

`Pistachio` class offers an entry point to all of these tools through its class method `Pistachio.compile`. This method takes a regular untouched `Pistachio` template string, and it returns `Compiler` output, while using `Normalizer` and `Parser` to feed the compiler with the correct parsed input.

```coffee
{ Pistachio } = require 'kdf-pistachio'

pistachio = 
  """
  {div.foo{ doFunStuffWithString 'Hello World' }}
  {{> @view}}
  """

compiled = Pistachio.compile pistachio
###
compiled result:
[new KDViewNode({
  tagName: 'div'
  cssClass: 'foo'
  subviews: [
    new KDTextNode({value: doFunStuffWithString('Hello World')})
  ]
}), this.view]
###
```

## Installation

```
npm install kdf-dom-operations
```