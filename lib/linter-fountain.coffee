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
            headerArray = []
            closingBraceHighestParsedIndex = -1
            lines = textEditor.getText().split(/\n/)

            for line, index in lines
                lineStart = index
                lineEnd = index
                start = null
                end = null
                level = null
                excerpt = null
                description = null

                @buildHeaderArray(headerArray, line, index)

                emptyHeading = @lintEmptyHeading(line)
                closingBraces = null
                if (index > closingBraceHighestParsedIndex)
                    closingBraces = @lintEnclosingCharacters(line, index, lines)
                    if (typeof closingBraces == 'number')
                        closingBraceHighestParsedIndex = closingBraces
                        closingBraces = null

                if (emptyHeading)
                    [start, end, level, excerpt, description] = emptyHeading
                else if (closingBraces)
                    [lineStart, start, lineEnd, end, level, excerpt, description] = closingBraces
                    closingBraceHighestParsedIndex = lineEnd

                if (start != null && end != null)
                    lintArray.push({
                        severity: level,
                        location: {
                          file: editorPath,
                          position: [[lineStart, start], [lineEnd, end]],
                        },
                        excerpt: excerpt,
                        description: description
                    })

            @applyHeaderLint(headerArray, lintArray, editorPath)
            lintArray

    buildHeaderArray: (headerArray, line, index) ->
        if (line)
            headerHashes = line.match(/(#)*/)[0]
            hashCount = headerHashes.length
            if (hashCount)
                headerArray.push({
                    hashCount: hashCount,
                    index: index
                })

    applyHeaderLint: (headerArray, lintArray, editorPath) ->
        for header, idx in headerArray
            if idx > 0
                diff = header.hashCount - headerArray[idx-1].hashCount
                if (diff > 1)
                    lintArray.push({
                        severity: "warning",
                        location: {
                          file: editorPath,
                          position: [[header.index, 0], [header.index, header.hashCount]],
                        },
                        excerpt: "Improperly Nested Heading",
                        description: "Heading element is not gradually nested (ex. going from '#' to '###')"
                    })

    lintEmptyHeading: (line) ->
        emptyHeading =  /^\s*#+(.*)/
        matchedLine = line.match(emptyHeading)
        if (matchedLine && !matchedLine[1].trim().length)
            [0, line.length, "warning", "Blank Heading", "This heading contains no textual content."]

    lintEnclosingCharacters: (line, originIndex, lines) ->

        if (line.match(/.*?[><\*_].*?/))

            sectionData = {
                startLineIndex: originIndex,
                endLineIndex: originIndex,
                endCharIndex: line.length
            }
            sectionString = line
            for singleLine, idx in lines
                if (idx > originIndex)
                    if (singleLine.trim())
                        sectionString += singleLine
                    else
                        sectionData.endLineIndex = idx-1
                        sectionData.endCharIndex = lines[idx-1].length
                        break

            centerError = false
            underlineError = false
            starCountArray = []
            starCount = 0
            skipNextChar = false
            for char, idx in sectionString
                if (skipNextChar)
                    skipNextChar = false
                else if (char == '\\')
                    skipNextChar = true
                else if (char == '<' || char == '>')
                    centerError = !centerError
                else if (char == '_')
                    underlineError = !underlineError
                else if (char == '*')
                    starCount++
                if (starCount && (char != '*' || idx == sectionString.length - 1))
                    starCountArray.push(starCount)
                    starCount = 0;

            isBalanced = starCountArray.length % 2 == 0
            if (isBalanced)
                for count, i in starCountArray
                    isBalanced = isBalanced &&
                        (count == starCountArray[starCountArray.length - 1 - i])

            if (centerError || underlineError || !isBalanced)
                [sectionData.startLineIndex, 0, sectionData.endLineIndex, sectionData.endCharIndex, "warning", "Style character missing", "This line is missing a stylistic character (i.e. *, _, >, or <)."]
            else
                sectionData.endLineIndex


