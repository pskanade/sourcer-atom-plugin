'use babel'
#PranavSourcerView = require './pranav-sourcer-view'
{CompositeDisposable} = require 'atom'
request = require 'request'
cheerio = require 'cheerio'

module.exports = PranavSourcer =
  # pranavSourcerView: null
  # modalPanel: null
  subscriptions: null

  activate: (state) ->
  #   @pranavSourcerView = new PranavSourcerView(state.pranavSourcerViewState)
  #   @modalPanel = atom.workspace.addModalPanel(item: @pranavSourcerView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'pranav-sourcer:fetch': => @fetch()

  deactivate: ->
    # @modalPanel.destroy()
    @subscriptions.dispose()
    # @pranavSourcerView.destroy()

  # serialize: ->
  #   pranavSourcerViewState: @pranavSourcerView.serialize()

  fetch: ->
    # self has to be defined as the global context cannot be passed to the callback functions.
    self = this
    if (editor = atom.workspace.getActiveTextEditor())
      selection = editor.getSelectedText()
      @download(selection).then((html) ->
        answer = self.scrape(html)
        if answer == ''
          atom.notifications.addWarning('No answer Found :(')
        else
          editor.insertText(answer)
        ).catch((error) ->
          console.log error
          atom.notifications.addWarning(error.reason))


  scrape:(html) ->
    $ = cheerio.load(html)
    $('div.accepted-answer pre code').text()

  download: (url) ->
    # added a promise object so that we can fetch the responce asynchronously
    new Promise (resolve, reject) ->
      request url, (error, response, body) ->
        if !error and response.statusCode == 200
          resolve body
        else
          reject {reason: 'Unable to download page'}
