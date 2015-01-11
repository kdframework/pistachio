###*
 * General pistachio definitions with attributes.
 *
 * @type {RegExp}
###
pistachios =
  ///
  \{                  # first { (begins symbol)
    ([\w|-]*)?        # optional custom html tag name
    (\#[\w|-]*)?      # optional id - #-prefixed
    ((?:\.[\w|-]*)*)  # optional class names - .-prefixed
    (\[               # optional [ begins the attributes
      (?:\b[\w|-]*\b) # the name of the attribute
      (?:\=           # optional assignment operator =
                      # TODO: this will tolerate fuzzy quotes for now. "e.g.'
        [\"|\']?      # optional quotes
        .*            # optional value
        [\"|\']?      # optional quotes
      )
    \])*              # optional ] closes the attribute tag(s). there can be many attributes.
    \{                # second { (begins expression)
      ([^{}]*)        # practically anything can go between the braces, except {}
    \}\s*             # closing } (ends expression)
  \}                  # closing } (ends symbol)
  ///g

###*
 * Slightly modified version of the general pistachio definition.
 * Instead of capturing the individual attributes
 * it captures them in one group. The rest is the same with
 * general `Pistachio` definition.
 *
 * @type {RegExp}
###
regularPistachios =
  ///
  \{                    # first { (begins symbol)
    ((?:[\w|-]*)?       # optional custom html tag name
    (?:\#[\w|-]*)?      # optional id - #-prefixed
    (?:(?:\.[\w|-]*)*)  # optional class names - .-prefixed
    (?:\[               # optional [ begins the attributes
      (?:\b[\w|-]*\b)   # the name of the attribute
      (?:\=             # optional assignment operator =
                        # TODO: this will tolerate fuzzy quotes for now. "e.g.'
        [\"|\']?        # optional quotes
        .*              # optional value
        [\"|\']?        # optional quotes
      )
    \])*)               # optional ] closes the attribute tag(s). there can be many attributes.
    \{                  # second { (begins expression)
      ([^{}]*)          # practically anything can go between the braces, except {}
    \}\s*               # closing } (ends expression)
  \}                    # closing } (ends symbol)
  ///g


###*
 * Simpler definition for normalized pistachios.
 * It doesn't care about the attributes. Only cares
 * about the pistachio.
 *
 * @type {RegExp}
###
normalizedPistachios =
  ///
  \{            # first { (begins symbol)
    \{          # second { (begins expression)
      ([^{}]*)  # practically anything can go between the braces, except {}
    \}\s*       # closing } (ends expression)
  \}            # closing } (ends symbol)
  ///g


###*
 * Definition for capturing the view statement
 * inside pistachio part. NOTE: This regular expression requires
 * the expression it is tested against to be without
 * mustaches. Expression with a mustache will simply
 * doesn't match with this definition.
 *
 * @type {RegExp}
###
VIEW_REGEX = /^(?:> ? )(.+)/

###*
 * Definition for capturing the data statements
 * inside pistachio part. NOTE: This regular expression requires
 * the expression it is tested against to be without
 * mustaches. Expression with a mustache will simply
 * doesn't match with this definition.
 *
 * @type {RegExp}
###
DATA_REGEX = /#\(([^)]*)\)/g

###*
 * Definition for splitting the expression
 * for `Pistachio` dom node representation while
 * keeping the matched expression in the split array.
 * If you capture the matched expression (wrapping the whole
 * regular expression with parentheses) `String::split` will
 * return the matched expression in the array instead of
 * omitting it.
 *
 * @type {RegExp}
###
SPLITTER_REGEX = /({{\s?(?:[^}]*)\s?}})/ig

module.exports = {
  pistachios
  regularPistachios
  normalizedPistachios
  VIEW_REGEX
  DATA_REGEX
  SPLITTER_REGEX
}
