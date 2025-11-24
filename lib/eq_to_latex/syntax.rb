# frozen_string_literal: true

module EqToLatex
  # Syntax definitions for converting Hangul equation script to LaTeX
  #
  # Rule Types:
  # - Keyword Command: No parameters (sum, int)
  # - Default Command: One right-hand parameter (sub, sup, bar)
  # - Block Command: begin/end blocks (matrix, cases)
  # - Meta: Special characters (left, right, newlines)
  # - Symbol: Mathematical symbols (Greek letters, operators)
  # - Reserved Word: Function names rendered in Roman font (sin, cos)
  module Syntax
    module_function

    # Helper to create a rule with case variations
    def rule(pattern, latex, alphabetic: true)
      { regex: pattern, latex: latex, alphabetic: alphabetic }.freeze
    end

    # Helper to create case-insensitive rule (lowercase, Titlecase, UPPERCASE)
    def ci_rule(word, latex)
      rule([word.downcase, word.capitalize, word.upcase], latex)
    end

    # ============================================================
    # KEYWORD COMMANDS - No parameters
    # ============================================================
    KEYWORD_COMMANDS = [
      ci_rule("eqalign", ""),
      ci_rule("rm", " \\rm "),
      ci_rule("it", " \\it "),
      ci_rule("sum", " \\sum "),
      rule(["int(?!er)", "Int(?!er)", "INT(?!ER)"], " \\int "),
      ci_rule("oint", " \\oint ")
    ].freeze

    # ============================================================
    # DEFAULT COMMANDS - One right-hand parameter
    # ============================================================
    DEFAULT_COMMANDS = [
      rule("sub(?!set)", "_"),
      rule("sup(?!set)", "^"),
      rule("box", "\\fbox"),
      rule("arch", "\\stackrel\\frown"),
      rule("bar", "\\overline"),
      rule("overline", "\\overline"),
      rule("acute", "\\acute"),
      rule("grave", "\\grave"),
      rule("check", "\\check"),
      rule("breve", "\\breve"),
      rule("tilde", "\\tilde"),
      rule("hat", "\\hat"),
      rule("widehat", "\\widehat"),
      rule("vec", "\\vec"),
      rule("dot(?!eq)", "\\dot"),
      rule("ddot(?!s)", "\\ddot"),
      rule("dyad", "\\overleftrightarrow"),
      rule("under", "\\underline")
    ].freeze

    # ============================================================
    # BLOCK COMMANDS - begin/end environments
    # ============================================================
    BLOCK_COMMANDS = [
      rule("cases", "cases"),
      rule("dmatrix", "vmatrix"),
      rule("bmatrix", "Bmatrix"),
      rule("pmatrix", "pmatrix"),
      rule("matrix", "matrix")
    ].freeze

    # ============================================================
    # META - Special characters and delimiters
    # ============================================================
    META = [
      # left/right without following bracket - remove
      rule('(?<![a-zA-Z])(?i:left|right)\b\s*+(?:(?=[^{}\[\]\|\(\)<>])|(?:$))', "", alphabetic: false),
      # Angle brackets
      rule('(?<![a-zA-Z])(?i:left)\s*<', " \\langle ", alphabetic: false),
      rule('(?<![a-zA-Z])(?i:right)\s*>', " \\rangle ", alphabetic: false),
      # Square brackets
      rule('(?<![a-zA-Z])(?i:left)\s*\[', " \\left [ ", alphabetic: false),
      rule('(?<![a-zA-Z])(?i:right)\s*\]', " \\right ] ", alphabetic: false),
      # Curly braces
      rule('(?<![a-zA-Z])(?i:left)\s*{', " \\{ ", alphabetic: false),
      rule('(?<![a-zA-Z])(?i:right)\s*}', " \\} ", alphabetic: false),
      rule('"{"', " \\{ ", alphabetic: false),
      rule('"}"', " \\} ", alphabetic: false),
      # Parentheses
      rule('(?<![a-zA-Z])(?i:left)\s*\(', " \\left ( ", alphabetic: false),
      rule('(?<![a-zA-Z])(?i:right)\s*\)', " \\right ) ", alphabetic: false),
      # Vertical bars
      rule('(?<![a-zA-Z])(?i:left)\s*\|', " \\left | ", alphabetic: false),
      rule('(?<![a-zA-Z])(?i:right)\s*\|', " \\right | ", alphabetic: false),
      # Special characters
      rule("`", " \\, ", alphabetic: false),          # thin space
      rule("#", "\\\\\\\\", alphabetic: false),       # line break
      rule("&amp;", "", alphabetic: false),           # alignment
      rule("\r?\n", "", alphabetic: false),           # newlines
      rule("%", " \\% ")                               # percent
    ].freeze

    # ============================================================
    # GREEK LETTERS
    # ============================================================
    GREEK_LETTERS = [
      # Lowercase Greek
      rule("alpha", " \\alpha "),
      rule("beta", " \\beta "),
      rule("gamma", " \\gamma "),
      rule("delta", " \\delta "),
      rule("epsilon", " \\epsilon "),
      rule("zeta", " \\zeta "),
      rule("eta", " \\eta "),
      rule("theta", " \\theta "),
      rule("iota", " \\iota "),
      rule("kappa", " \\kappa "),
      rule("lambda", " \\lambda "),
      rule("mu", " \\mu "),
      rule("nu", " \\nu "),
      rule("xi", " \\xi "),
      rule("omicron", " \\omicron "),
      rule("pi", " \\pi "),
      rule("rho", " \\rho "),
      rule("sigma", " \\sigma "),
      rule("tau", " \\tau "),
      rule("upsilon", " \\upsilon "),
      rule("phi", " \\phi "),
      rule("chi", " \\chi "),
      rule("psi", " \\psi "),
      rule("omega", " \\omega "),
      # Uppercase Greek (with LaTeX commands)
      rule(["Gamma", "GAMMA"], " \\Gamma "),
      rule(["Delta", "DELTA"], " \\Delta "),
      rule(["Theta", "THETA"], " \\Theta "),
      rule(["Lambda", "LAMBDA"], " \\Lambda "),
      rule(["Xi", "XI"], " \\Xi "),
      rule(["Pi", "PI"], " \\Pi "),
      rule(["Sigma", "SIGMA"], " \\Sigma "),
      rule(["Phi", "PHI"], " \\Phi "),
      rule(["Psi", "PSI"], " \\Psi "),
      rule(["Omega", "OMEGA"], " \\Omega "),
      # Uppercase Greek (italic, no LaTeX command)
      rule(["Alpha", "ALPHA"], " \\mathit {A} "),
      rule(["Beta", "BETA"], " \\mathit {B} "),
      rule(["Epsilon", "EPSILON"], "\\mathit {E}"),
      rule(["Zeta", "ZETA"], "\\mathit {Z}"),
      rule(["Eta", "ETA"], "\\mathit {H}"),
      rule(["Iota", "IOTA"], "\\mathit {I}"),
      rule(["Kappa", "KAPPA"], "\\mathit {K}"),
      rule(["Mu", "MU"], "\\mathit {M}"),
      rule(["Nu", "NU"], "\\mathit {N}"),
      rule(["Omicron", "OMICRON"], " \\mathit {O} "),
      rule(["Rho", "RHO"], "\\mathit {P}"),
      rule(["Tau", "TAU"], "\\mathit {T}"),
      rule(["Upsilon", "UPSILON"], "\\mathit {Y}"),
      rule(["Chi", "CHI"], "\\mathit {X}"),
      # Variant forms
      rule("vartheta", " \\vartheta "),
      rule("varpi", " \\varpi "),
      rule("varsigma", " \\varsigma "),
      rule("varupsilon", " \\Upsilon "),
      rule("varphi", " \\varphi "),
      rule("varepsilon", " \\varepsilon "),
      rule("varrho", " \\varrho ")
    ].freeze

    # ============================================================
    # SPECIAL SYMBOLS
    # ============================================================
    SPECIAL_SYMBOLS = [
      ci_rule("aleph", " \\aleph "),
      ci_rule("hbar", " \\hbar "),
      ci_rule("imath", " \\imath "),
      ci_rule("jmath", " \\jmath "),
      ci_rule("ell", " \\ell "),
      ci_rule("liter", " \\ell "),
      ci_rule("wp", " \\wp "),
      ci_rule("mho", " \\mho "),
      rule("IMAG", " \\Im "),
      rule("ANGSTROM", " \\mathit {\\unicode{x212b}} "),
      rule("prime", " ' ")
    ].freeze

    # ============================================================
    # SET OPERATIONS
    # ============================================================
    SET_OPERATIONS = [
      rule(["prod", "PROD"], " \\prod "),
      ci_rule("coprod", " \\coprod "),
      ci_rule("inter", " \\bigcap "),
      ci_rule("bigcap", " \\bigcap "),
      ci_rule("union", " \\bigcup "),
      ci_rule("bigcup", " \\bigcup "),
      ci_rule("cap", " \\cap "),
      ci_rule("smallinter", " \\cap "),
      ci_rule("cup", " \\cup "),
      ci_rule("smallunion", " \\cup "),
      ci_rule("sqcap", " \\sqcap "),
      ci_rule("sqcup", " \\sqcup "),
      ci_rule("bigsqcup", " \\bigsqcup "),
      ci_rule("uplus", " \\uplus "),
      ci_rule("biguplus", " \\biguplus "),
      ci_rule("subset", " \\subset "),
      ci_rule("supset", " \\supset "),
      ci_rule("subseteq", " \\subseteq "),
      ci_rule("supseteq", " \\supseteq "),
      ci_rule("nsubseteq", " \\nsubseteq "),
      ci_rule("nsupseteq", " \\nsupseteq "),
      ci_rule("sqsubset", " \\sqsubset "),
      ci_rule("sqsupset", " \\sqsupset "),
      ci_rule("sqsubseteq", " \\sqsubseteq "),
      ci_rule("sqsupseteq", " \\sqsupseteq "),
      rule(["in(?!t|f)", "In(?!t|f)", "IN(?!T|F)"], " \\in "),
      rule(["not(?!in)", "Not(?!in)", "NOT(?!IN)"], " \\not "),
      ci_rule("ni", " \\ni "),
      ci_rule("owns", " \\owns "),
      ci_rule("notin", " \\not \\in "),
      ci_rule("nin", " \\not \\in "),
      ci_rule("notni", " \\not \\ni ")
    ].freeze

    # ============================================================
    # COMPARISON OPERATORS
    # ============================================================
    COMPARISON_OPERATORS = [
      ci_rule("leq", " \\leq "),
      ci_rule("le", " \\le "),
      rule("<=", " \\leqq ", alphabetic: false),
      ci_rule("geq", " \\geq "),
      ci_rule("ge", " \\ge "),
      rule(">=", " \\geqq ", alphabetic: false),
      rule('(?<![>\-])(?:(?<!\s)>|>(?!\s))(?![=>])', " > ", alphabetic: false),
      rule('(?<![s<])(?:(?<!\s)<|<(?!\s))(?![<=])', " < ", alphabetic: false),
      rule("(?<!<)<<(?!<)", " \\ll ", alphabetic: false),
      rule("(?<!>)>>(?!>)", " \\gg ", alphabetic: false),
      rule("<<<", " \\lll ", alphabetic: false),
      ci_rule("lll", " \\lll "),
      rule(">>>", " \\ggg ", alphabetic: false),
      rule("ggg", " \\ggg "),
      rule(["prec", "PREC"], " \\prec "),
      ci_rule("succ", " \\succ ")
    ].freeze

    # ============================================================
    # BINARY OPERATORS
    # ============================================================
    BINARY_OPERATORS = [
      rule('\+\-', " \\pm ", alphabetic: false),
      ci_rule("plusminus", " \\pm "),
      rule('\-\+', " \\mp ", alphabetic: false),
      ci_rule("minusplus", " \\mp "),
      ci_rule("dsum", " \\dotplus "),
      ci_rule("times", " \\times "),
      ci_rule("divide", " \\div "),
      ci_rule("div", " \\div "),
      ci_rule("circ", " \\circ "),
      ci_rule("bullet", " \\bullet "),
      rule(["Deg", "DEG"], " \\,^{\\circ} "),
      ci_rule("ast", " \\ast "),
      ci_rule("star", " \\star "),
      ci_rule("bigcirc", " \\bigcirc "),
      ci_rule("oplus", " \\oplus "),
      ci_rule("ominus", " \\ominus "),
      ci_rule("otimes", " \\otimes "),
      ci_rule("odot", " \\odot "),
      ci_rule("oslash", " \\oslash ")
    ].freeze

    # ============================================================
    # LOGICAL OPERATORS
    # ============================================================
    LOGICAL_OPERATORS = [
      ci_rule("lor", " \\lor "),
      ci_rule("vee", " \\vee "),
      ci_rule("bigvee", " \\bigvee "),
      ci_rule("land", " \\land "),
      ci_rule("wedge", " \\wedge "),
      ci_rule("bigwedge", " \\bigwedge "),
      ci_rule("xor", " \\veebar "),
      rule(["LNOT"], " \\lnot "),
      ci_rule("neg", " \\neg ")
    ].freeze

    # ============================================================
    # RELATION SYMBOLS
    # ============================================================
    RELATION_SYMBOLS = [
      ci_rule("ne", " \\ne "),
      rule("!=", " \\ne ", alphabetic: false),
      ci_rule("neq", " \\neq "),
      ci_rule("doteq", " \\doteq "),
      rule(["image", "Image"], " \\fallingdotseq "),
      ci_rule("reimage", " \\risingdotseq "),
      ci_rule("sim", " \\backsim "),
      rule("∾", " \\backsim ", alphabetic: false),
      rule('\xf3\xb0\x81\x80', " \\backsim ", alphabetic: false),
      ci_rule("simeq", " \\simeq "),
      ci_rule("approx", " \\approx "),
      ci_rule("cong", " \\cong "),
      ci_rule("equiv", " \\equiv "),
      rule("==", " \\equiv ", alphabetic: false),
      ci_rule("asymp", " \\asymp "),
      ci_rule("iso", " \\Bumpeq "),
      ci_rule("propto", " \\propto ")
    ].freeze

    # ============================================================
    # MISCELLANEOUS SYMBOLS
    # ============================================================
    MISC_SYMBOLS = [
      ci_rule("emptyset", " \\emptyset "),
      ci_rule("therefore", " \\therefore "),
      ci_rule("because", " \\because "),
      rule(["exists?", "Exists?", "EXISTS?"], " \\exists "),
      ci_rule("diamond", " \\diamond "),
      rule(["Forall", "FORALL"], " \\forall "),
      ci_rule("partial", " \\partial "),
      ci_rule("infty", " \\infty "),
      ci_rule("inf", " \\infty "),
      ci_rule("infinity", " \\infty "),
      ci_rule("dagger", " \\dagger "),
      ci_rule("ddagger", " \\ddagger "),
      ci_rule("parallel", " \\parallel ")
    ].freeze

    # ============================================================
    # ARROWS
    # ============================================================
    ARROWS = [
      rule(["larrow", "leftarrow"], " \\leftarrow "),
      rule(["Leftarrow", "LEFTARROW", "LARROW", "Larrow"], " \\Leftarrow "),
      rule(["rarrow", "rightarrow"], " \\rightarrow "),
      rule(["Rightarrow", "RIGHTARROW", "RARROW", "Rarrow"], " \\Rightarrow "),
      rule("uparrow", " \\uparrow "),
      rule(["Uparrow", "UPARROW"], " \\Uparrow "),
      rule("downarrow", " \\downarrow "),
      rule(["Downarrow", "DOWNARROW"], " \\Downarrow "),
      rule("udarrow", " \\updownarrow "),
      rule(["Udarrow", "UDARROW"], " \\Updownarrow "),
      rule("lrarrow", " \\leftrightarrow "),
      rule(["Lrarrow", "LRARROW"], " \\Leftrightarrow "),
      ci_rule("nwarrow", " \\nwarrow "),
      ci_rule("searrow", " \\searrow "),
      ci_rule("nearrow", " \\nearrow "),
      ci_rule("swarrow", " \\swarrow "),
      ci_rule("hookleft", " \\hookleftarrow "),
      ci_rule("hookright", " \\hookrightarrow "),
      ci_rule("mapsto", " \\mapsto "),
      rule("->", " \\to ", alphabetic: false)
    ].freeze

    # ============================================================
    # DELIMITERS AND DOTS
    # ============================================================
    DELIMITERS = [
      rule(["Vert", "VERT"], " \\Vert "),
      rule("vert", " \\vert "),
      ci_rule("backslash", " \\backslash "),
      rule(["cdot(?!s)", "Cdot(?!s)", "CDOT(?!S)"], " \\cdot "),
      ci_rule("cdots", " \\cdots "),
      ci_rule("ldots", " \\ldots "),
      ci_rule("vdots", " \\vdots "),
      ci_rule("ddots", " \\ddots ")
    ].freeze

    # ============================================================
    # GEOMETRY SYMBOLS
    # ============================================================
    GEOMETRY_SYMBOLS = [
      rule(["triangle(?![dlr])", "Triangle(?![dlr])", "TRIANGLE(?![DLR])"], " \\triangle "),
      ci_rule("triangled", " \\triangledown "),
      ci_rule("trianglel", " \\triangleleft "),
      ci_rule("triangler", " \\triangleright "),
      ci_rule("nabla", " \\nabla "),
      ci_rule("angle", " \\angle "),
      ci_rule("langle", " \\langle "),
      ci_rule("rangle", " \\rangle "),
      ci_rule("msangle", " \\measuredangle "),
      ci_rule("sangle", " \\sphericalangle "),
      ci_rule("vdash", " \\vdash "),
      ci_rule("hright", " \\vdash "),
      ci_rule("dashv", " \\dashv "),
      ci_rule("hleft", " \\dashv "),
      ci_rule("bot", " \\bot "),
      ci_rule("top", " \\top "),
      rule(["Models", "MODELS"], " \\models "),
      ci_rule("laplace", " \\mathscr {L} "),
      ci_rule("centigrade", " \\,^{\\circ}\\mathrm {C} "),
      ci_rule("fahrenheit", " \\,^{\\circ}\\mathrm {F} "),
      ci_rule("amalg", " \\amalg "),
      ci_rule("lfloor", " \\lfloor "),
      ci_rule("rfloor", " \\rfloor "),
      ci_rule("lceil", " \\lceil "),
      ci_rule("rceil", " \\rceil ")
    ].freeze

    # ============================================================
    # RESERVED WORDS - Function names (rendered in Roman font)
    # ============================================================
    RESERVED_WORD = [
      # Trigonometric functions
      rule('(?<!mathrm\s{)sin(?!h)', " \\mathrm {sin} "),
      rule('(?<!mathrm\s{)cos(?!ec|h)', " \\mathrm {cos} "),
      rule('(?<!mathrm\s{)tan(?!h)', " \\mathrm {tan} "),
      rule('(?<!mathrm\s{)cot(?!h)', " \\mathrm {cot} "),
      rule('(?<!mathrm\s{)sec', " \\mathrm {sec} "),
      rule('(?<!mathrm\s{)cosec', " \\mathrm {cosec} "),
      rule('(?<!mathrm\s{)csc', " \\mathrm {csc} "),
      # Inverse trig
      rule('(?<!mathrm\s{)arcsin', " \\mathrm {arcsin} "),
      rule('(?<!mathrm\s{)arccos', " \\mathrm {arccos} "),
      rule('(?<!mathrm\s{)arctan', " \\mathrm {arctan} "),
      rule('(?<!mathrm\s{)arc(?!h|sin|cos|tan)', " \\mathrm {arc} "),
      # Hyperbolic functions
      rule('(?<!mathrm\s{)sinh', " \\mathrm {sinh} "),
      rule('(?<!mathrm\s{)cosh', " \\mathrm {cosh} "),
      rule('(?<!mathrm\s{)tanh', " \\mathrm {tanh} "),
      rule('(?<!mathrm\s{)coth', " \\mathrm {coth} "),
      # Logarithms
      rule('(?<!mathrm\s{)log', " \\mathrm {log} "),
      rule('(?<!mathrm\s{)ln(?!ot)', " \\mathrm {ln} "),
      rule('(?<!mathrm\s{)lg', " \\mathrm {lg} "),
      rule('(?<!mathrm\s{)exp', " \\mathrm {exp} "),
      rule('(?<!mathrm\s{)Exp', " \\mathrm {Exp} "),
      # Limits and special functions
      rule('(?<!mathrm\s{)lim', " \\mathrm {lim} "),
      rule('(?<!mathrm\s{)Lim', " \\mathrm {Lim} "),
      rule('(?<!mathrm\s{)max', " \\mathrm {max} "),
      rule('(?<!mathrm\s{)min', " \\mathrm {min} "),
      rule('(?<!mathrm\s{)det', " \\mathrm {det} "),
      rule('(?<!mathrm\s{)gcd', " \\mathrm {gcd} "),
      rule('(?<!mathrm\s{)mod', " \\mathrm {mod} "),
      # Keywords
      rule('(?<!mathrm\s{)if', " \\mathrm {if} "),
      rule('(?<!mathrm\s{)for', " \\mathrm {for} "),
      rule('(?<!mathrm\s{)and', " \\mathrm {and} "),
      # Algebra
      rule('(?<!mathrm\s{)hom', " \\mathrm {hom} "),
      rule('(?<!mathrm\s{)ker', " \\mathrm {ker} "),
      rule('(?<!mathrm\s{)deg', " \\mathrm {deg} "),
      rule('(?<!mathrm\s{)arg', " \\mathrm {arg} "),
      rule('(?<!mathrm\s{)dim', " \\mathrm {dim} "),
      rule('(?<!mathrm\s{)Pr', " \\mathrm {Pr} ")
    ].freeze

    # Combined symbol list for simple replacement
    SYMBOL = (
      GREEK_LETTERS +
      SPECIAL_SYMBOLS +
      SET_OPERATIONS +
      COMPARISON_OPERATORS +
      BINARY_OPERATORS +
      LOGICAL_OPERATORS +
      RELATION_SYMBOLS +
      MISC_SYMBOLS +
      ARROWS +
      DELIMITERS +
      GEOMETRY_SYMBOLS
    ).freeze

    # Build regex pattern from a rule
    def rule_regex(rule)
      patterns = Array(rule[:regex])
      alphabetic = rule[:alphabetic] != false

      prefix = alphabetic ? '(?<![a-zA-Z\\\\])' : '(?<![\\\\])'
      Regexp.new("#{prefix}(#{patterns.join('|')})")
    end
  end
end
