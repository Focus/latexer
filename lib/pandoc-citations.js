const jsYaml = require('js-yaml');
const pathm = require('./path-manipulation');

module.exports = {
  isPandocStyleCitation(text) {
    const citationPattern = /\[[^\[]*\s*@$/;
    return citationPattern.test(text);
  },
  getBibfilesFromYAML(yaml) {
    // Be prepared to handle a YAML array of bibfiles
    const yamlBibFiles = jsYaml.safeLoad(yaml).bibliography;
    let resolvedBibFiles;

    if (yamlBibFiles) {
      resolvedBibFiles =
      [].concat(yamlBibFiles)
        .map(pathm.resolveAbsolutePathToBibFile);
    }
    return resolvedBibFiles;
  },
  extractYAMLmetadata(text) {
    const yamlDelimiter = /(?:\-\-\-)|(?:\.\.\.)/;
    // Split the text twice using the delimiter, yielding three substrings.
    // The middle substring [1] is what's between the delimiters.
    const yamlBlock = text.split(yamlDelimiter, 2)[1];
    return yamlBlock;
  }
};
