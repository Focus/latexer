fsPlus = require 'fs-plus'
fs = require 'fs-plus'
path = require 'path'

module.exports =
FindLabels =
  getLabelsByText: (text, baseFile = "") ->
    labelRex = /\\(?:th)?label{([^}]+)}/g
    matches = []
    while (match = labelRex.exec(text))
      matches.push {label: match[1]}
    return matches unless baseFile?
    inputRex = /\\(input|include){([^}]+)}/g
    while (match = inputRex.exec(text))
      matches = matches.concat(
        @getLabels(@getAbsolutePath(baseFile, match[2]), baseFile))
    inputRex = /\\(subimport){([^}]+)}{([^}]+)}/g
    while (match = inputRex.exec(text))
      matches = matches.concat(@getLabels(
        @getAbsolutePath(baseFile, match[2]+match[3]), baseFile))
    matches

  getLabels: (file, baseFile) ->
    #if file is not there try add possible extensions
    if not fsPlus.isFileSync(file)
      file = fsPlus.resolveExtension(file, ['tex'])
    return [] unless fsPlus.isFileSync(file)
    text = fs.readFileSync(file).toString()
    @getLabelsByText(text, baseFile)

  getAbsolutePath: (file, relativePath) ->
    if (ind = file.lastIndexOf(path.sep)) isnt file.length
      file = file.substring(0,ind)
    path.resolve(file, relativePath)
