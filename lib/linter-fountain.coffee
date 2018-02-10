{CompositeDisposable} = require 'atom'

module.exports =

#    subscriptions: null

    activate: ->
        require('atom-package-deps').install('linter-fountain')
#        @subscriptions = new CompositeDisposable()
        console.log(">>> PACKAGE \"fountain-linter\" ACTIVATED <<<")

    dectivate: ->
        console.log(">>> PACKAGE \"fountain-linter\" DEACTIVATED <<<")

    provideLinter: ->
        name: 'linter-fountain',
        grammarScopes: ['source.fountain'],
        scope: 'file',
        lintOnChange: true,
        lint: (textEditor) =>
            console.log("boob")
            console.log(arguments)
            console.log(textEditor)

