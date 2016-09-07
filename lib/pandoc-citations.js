const jsYaml = require('js-yaml');

module.exports = {
  isPandocStyleCitation(text) {
    const citationPattern = /\[[^\[]*\s*@$/;
    return citationPattern.test(text);
  },
  getBibfileFromYAML(yaml) {
    const bibFile = jsYaml.safeLoad(yaml).bibliography;
    return bibFile;
  },
  extractYAMLmetadata(text) {
    const yamlDelimiter = /(?:\-\-\-)|(?:\.\.\.)/;
    // Split the text twice using the delimiter, yielding three substrings.
    // The middle substring [1] is what's between the delimiters.
    const yamlBlock = text.split(yamlDelimiter, 2)[1];
    return yamlBlock;
  },
};
