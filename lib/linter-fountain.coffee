{CompositeDisposable} = require 'atom'

module.exports =

    activate: ->
        require('atom-package-deps').install('linter-fountain')

    dectivate: ->

    provideLinter: ->
        name: 'linter-fountain',
        grammarScopes: ['source.fountain'],
        scope: 'file',
        lintsOnChange: true,
        lint: (textEditor) =>
            editorPath = textEditor.getPath()
            lintArray = []
            lines = textEditor.getText().split(/\n/)
            for line, index in lines
                start = null
                end = null
                level = null
                excerpt = null
                description = null
                [start, end, level, excerpt, description] = @lintLine(line)
                if (start != null && end != null)
                    lintArray.push({
                        severity: level,
                        location: {
                          file: editorPath,
                          position: [[index, start], [index, end]],
                        },
                        excerpt: excerpt,
                        description: description
                    })
            lintArray

    lintLine: (line) ->
        emptyHeading =  /^\s*#+(.*)/
        matchedLine = line.match(emptyHeading)
        if (matchedLine && !matchedLine[1].trim().length)
            [0, line.length, "warning", "Blank Heading", "This heading contains no textual content."]
        else
            [null, null, null, null, null]