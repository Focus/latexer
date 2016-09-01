module.exports = {
  isPandocStyleCitation(text) {
    const citationPattern = /\[[^\[]*\s*@$/;
    return citationPattern.test(text);
  },
};
