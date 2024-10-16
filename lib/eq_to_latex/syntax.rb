#
#  Author: osh
#  Created: 2019-05-27
#  Last modified: 2019-05-27

module EqToLatex
  module Syntax
    # Keyword Command: 파라미터가 없는 명령어
    # Default Command: 우측에 1개의 파라미터를 가지는 명령어
    # Block Command: begin/end 블록을 가지는 명령어(행렬, 케이스)
    # Meta: 공백, 줄바꿈, left right 등 특수문자
    # Symbol: 기호
    # Reserved Word: 로만체로 표시되는 예약어

    KEYWORD_COMMANDS = [
      {
        regex: ["eqalign", "Eqalign", "EQALIGN"],
        latex: ""
      },
      {
        regex: ["rm", "Rm", "RM"],
        latex: " \\rm "
      },
      {
        regex: ["it", "It", "IT"],
        latex: " \\it "
      },
      {
        regex: ["sum", "Sum", "SUM"],
        latex: " \\sum "
      },
      {
        regex: ["int(?!er)", "Int(?!er)", "INT(?!ER)"],
        latex: " \\int "
      },
      {
        regex: ["oint", "Oint", "OINT"],
        latex: " \\oint "
      }
    ]

    DEFAULT_COMMANDS = [
      {
        regex: "sub(?!set)",
        latex: "_"
      },
      {
        regex: "sup(?!set)",
        latex: "^"
      },
      {
        regex: "box",
        latex: "\\fbox"
      },
      {
        regex: "arch",
        latex: "\\stackrel\\frown"
      },
      {
        regex: "bar",
        latex: "\\overline"
      },
      {
        regex: "overline",
        latex: "\\overline"
      },
      {
        regex: "acute",
        latex: "\\acute"
      },
      {
        regex: "grave",
        latex: "\\grave"
      },
      {
        regex: "check",
        latex: "\\check"
      },
      {
        regex: "breve",
        latex: "\\breve"
      },
      {
        regex: "tilde",
        latex: "\\tilde"
      },
      {
        regex: "hat",
        latex: "\\hat"
      },
      {
        regex: "widehat",
        latex: "\\widehat"
      },
      {
        regex: "vec",
        latex: "\\vec"
      },
      {
        regex: "dot(?!eq)",
        latex: "\\dot"
      },
      {
        regex: "ddot(?!s)",
        latex: "\\ddot"
      },
      {
        regex: "dyad",
        latex: "\\overleftrightarrow"
      },
      {
        regex: "under",
        latex: "\\underline"
      }
    ]

    BLOCK_COMMANDS = [
      {
        regex: "cases",
        latex: "cases"
      },
      {
        regex: "dmatrix",
        latex: "vmatrix"
      },
      {
        regex: "bmatrix",
        latex: "Bmatrix"
      },
      {
        regex: "pmatrix",
        latex: "pmatrix"
      },
      {
        regex: "matrix",
        latex: "matrix"
      }
    ]

    META = [
      {
        regex: "(?<![a-zA-Z])(?i:left|right)\\b\\s*+(?:(?=[^{}\\[\\]\\|\\(\\)<>])|(?:$))",
        latex: "",
        alphabetic: false
      },
      {
        regex: "(?<![a-zA-Z])(?i:left)\\s*<",
        latex: " \\langle ",
        alphabetic: false
      },
      {
        regex: "(?<![a-zA-Z])(?i:right)\\s*>",
        latex: " \\rangle ",
        alphabetic: false
      },
      {
        regex: "(?<![a-zA-Z])(?i:left)\\s*\\[",
        latex: " \\left [ ",
        alphabetic: false
      },
      {
        regex: "(?<![a-zA-Z])(?i:right)\\s*\\]",
        latex: " \\right ] ",
        alphabetic: false
      },
      {
        regex: "(?<![a-zA-Z])(?i:left)\\s*{",
        latex: " \\{ ",
        alphabetic: false
      },
      {
        regex: "(?<![a-zA-Z])(?i:right)\\s*}",
        latex: " \\} ",
        alphabetic: false
      },
      {
        regex: "\"{\"",
        latex: " \\{ ",
        alphabetic: false
      },
      {
        regex: "\"}\"",
        latex: " \\} ",
        alphabetic: false
      },
      {
        regex: "(?<![a-zA-Z])(?i:right)\\s*}",
        latex: " \\} ",
        alphabetic: false
      },
      {
        regex: "(?<![a-zA-Z])(?i:left)\\s*\\(",
        latex: " \\left ( ",
        alphabetic: false
      },
      {
        regex: "(?<![a-zA-Z])(?i:right)\\s*\\)",
        latex: " \\right ) ",
        alphabetic: false
      },
      {
        regex: "(?<![a-zA-Z])(?i:left)\\s*\\|",
        latex: " \\left | ",
        alphabetic: false
      },
      {
        regex: "(?<![a-zA-Z])(?i:right)\\s*\\|",
        latex: " \\right | ",
        alphabetic: false
      },
      {
        regex: "`",
        latex: " \\, ",
        alphabetic: false
      },
      {
        regex: "#",
        latex: "\\\\\\\\",
        alphabetic: false
      },
      {
        regex: "&amp;",
        latex: "",
        alphabetic: false
      },
      {
        regex: "\r?\n",
        latex: "",
        alphabetic: false
      },
      {
        regex: "%",
        latex: " \\% "
      }
    ]

    SYMBOL = [
      {
        regex: ["Alpha", "ALPHA"],
        latex: " \\mathit {A} "
      },
      {
        regex: "alpha",
        latex: " \\alpha "
      },
      {
        regex: ["Beta", "BETA"],
        latex: " \\mathit {B} "
      },
      {
        regex: "beta",
        latex: " \\beta "
      },
      {
        regex: ["Gamma","GAMMA"],
        latex: " \\Gamma "
      },
      {
        regex: "gamma",
        latex: " \\gamma "
      },
      {
        regex: ["Delta","DELTA"],
        latex: " \\Delta "
      },
      {
        regex: "delta",
        latex: " \\delta "
      },
      {
        regex: ["Epsilon","EPSILON"],
        latex: "\\mathit {E}"
      },
      {
        regex: "epsilon",
        latex: " \\epsilon "
      },
      {
        regex: ["Zeta","ZETA"],
        latex: "\\mathit {Z}"
      },
      {
        regex: "zeta",
        latex: " \\zeta "
      },
      {
        regex: ["Eta","ETA"],
        latex: "\\mathit {H}"
      },
      {
        regex: "eta",
        latex: " \\eta "
      },
      {
        regex: ["Theta","THETA"],
        latex: " \\Theta "
      },
      {
        regex: "theta",
        latex: " \\theta "
      },
      {
        regex: ["Iota","IOTA"],
        latex: "\\mathit {I}"
      },
      {
        regex: "iota",
        latex: " \\iota "
      },
      {
        regex: ["Kappa","KAPPA"],
        latex: "\\mathit {K}"
      },
      {
        regex: "kappa",
        latex: " \\kappa "
      },
      {
        regex: ["Lambda","LAMBDA"],
        latex: " \\Lambda "
      },
      {
        regex: "lambda",
        latex: " \\lambda "
      },
      {
        regex: ["Mu","MU"],
        latex: "\\mathit {M}"
      },
      {
        regex: "mu",
        latex: " \\mu "
      },
      {
        regex: ["Nu","NU"],
        latex: "\\mathit {N}"
      },
      {
        regex: "nu",
        latex: " \\nu "
      },
      {
        regex: ["Xi","XI"],
        latex: " \\Xi "
      },
      {
        regex: "xi",
        latex: " \\xi "
      },
      {
        regex: ["Omicron", "OMICRON"],
        latex: " \\mathit {O} "
      },
      {
        regex: "omicron",
        latex: " \\omicron "
      },
      {
        regex: ["Pi","PI"],
        latex: " \\Pi "
      },
      {
        regex: "pi",
        latex: " \\pi "
      },
      {
        regex: ["Rho","RHO"],
        latex: "\\mathit {P}"
      },
      {
        regex: "rho",
        latex: " \\rho "
      },
      {
        regex: ["Sigma", "SIGMA"],
        latex: " \\Sigma "
      },
      {
        regex: "sigma",
        latex: " \\sigma "
      },
      {
        regex: ["Tau","TAU"],
        latex: "\\mathit {T}"
      },
      {
        regex: "tau",
        latex: " \\tau "
      },
      {
        regex: ["Upsilon","UPSILON"],
        latex: "\\mathit {Y}"
      },
      {
        regex: "upsilon",
        latex: " \\upsilon "
      },
      {
        regex: ["Phi","PHI"],
        latex: " \\Phi "
      },
      {
        regex: "phi",
        latex: " \\phi "
      },
      {
        regex: ["Chi","CHI"],
        latex: "\\mathit {X}"
      },
      {
        regex: "chi",
        latex: " \\chi "
      },
      {
        regex: ["Psi","PSI"],
        latex: " \\Psi "
      },
      {
        regex: "psi",
        latex: " \\psi "
      },
      {
        regex: ["Omega","OMEGA"],
        latex: " \\Omega "
      },
      {
        regex: "omega",
        latex: " \\omega "
      },
      {
        regex: ["aleph", "Aleph", "ALEPH"],
        latex: " \\aleph "
      },
      {
        regex: ["hbar", "Hbar", "HBAR"],
        latex: " \\hbar "
      },
      {
        regex: ["imath", "Imath", "IMATH"],
        latex: " \\imath "
      },
      {
        regex: ["jmath", "Jmath", "JMATH"],
        latex: " \\jmath "
      },
      {
        regex: ["ell", "Ell", "ELL"],
        latex: " \\ell "
      },
      {
        regex: ["liter", "Liter", "LITER"],
        latex: " \\ell "
      },
      {
        regex: ["wp", "Wp", "WP"],
        latex: " \\wp "
      },
      {
        regex: "IMAG",
        latex: " \\Im "
      },
      {
        regex: "ANGSTROM",
        latex: " \\mathit {\\unicode{x212b}} "
      },
      {
        regex: "vartheta",
        latex: " \\vartheta "
      },
      {
        regex: "varpi",
        latex: " \\varpi "
      },
      {
        regex: "varsigma",
        latex: " \\varsigma "
      },
      {
        regex: "varupsilon",
        latex: " \\Upsilon "
      },
      {
        regex: "varphi",
        latex: " \\varphi "
      },
      {
        regex: "varepsilon",
        latex: " \\varepsilon "
      },
      {
        regex: ["mho", "Mho", "MHO"],
        latex: " \\mho "
      },
      {
        regex: "varrho",
        latex: " \\varrho "
      },


      {
        regex: ["prod", "PROD"],
        latex: " \\prod "
      },
      {
        regex: ["coprod", "Coprod", "COPROD"],
        latex: " \\coprod "
      },
      {
        regex: ["inter", "Inter", "INTER"],
        latex: " \\bigcap "
      },
      {
        regex: ["bigcap", "Bigcap", "BIGCAP"],
        latex: " \\bigcap "
      },
      {
        regex: ["union", "Union", "UNION"],
        latex: " \\bigcup "
      },
      {
        regex: ["bigcup", "Bigcup", "BIGCUP"],
        latex: " \\bigcup "
      },
      {
        regex: ["cap", "Cap", "CAP"],
        latex: " \\cap "
      },
      {
        regex: ["smallinter", "Smallinter", "SMALLINTER"],
        latex: " \\cap "
      },
      {
        regex: ["cup", "Cup", "CUP"],
        latex: " \\cup "
      },
      {
        regex: ["smallunion", "Smallunion", "SMALLUNION"],
        latex: " \\cup "
      },
      {
        regex: ["sqcap", "Sqcap", "SQCAP"],
        latex: " \\sqcap "
      },
      {
        regex: ["sqcup", "Sqcup", "SQCUP"],
        latex: " \\sqcup "
      },
      {
        regex: ["bigsqcup", "Bigsqcup", "BIGSQCUP"],
        latex: " \\bigsqcup "
      },
      {
        regex: ["uplus", "Uplus", "UPLUS"],
        latex: " \\uplus "
      },
      {
        regex: ["biguplus", "Biguplus", "BIGUPLUS"],
        latex: " \\biguplus "
      },
      {
        regex: ["subset", "Subset", "SUBSET"],
        latex: " \\subset "
      },
      {
        regex: ["supset", "Supset", "SUPSET"],
        latex: " \\supset "
      },
      {
        regex: ["subseteq", "Subseteq", "SUBSETEQ"],
        latex: " \\subseteq "
      },
      {
        regex: ["supseteq", "Supseteq", "SUPSETEQ"],
        latex: " \\supseteq "
      },
      {
        regex: ["nsubseteq", "Nsubseteq", "NSUBSETEQ"],
        latex: " \\nsubseteq "
      },
      {
        regex: ["nsupseteq", "Nsupseteq", "NSUPSETEQ"],
        latex: " \\nsupseteq "
      },
      {
        regex: ["sqsubset", "Sqsubset", "SQSUBSET"],
        latex: " \\sqsubset "
      },
      {
        regex: ["sqsupset", "Sqsupset", "SQSUPSET"],
        latex: " \\sqsupset "
      },
      {
        regex: ["sqsubseteq", "Sqsubseteq", "SQSUBSETEQ"],
        latex: " \\sqsubseteq "
      },
      {
        regex: ["sqsupseteq", "Sqsupseteq", "SQSUPSETEQ"],
        latex: " \\sqsupseteq "
      },
      {
        regex: ["in(?!t|f)", "In(?!t|f)", "IN(?!T|F)"],
        latex: " \\in "
      },
      {
        regex: ["not(?!in)", "Not(?!in)", "NOT(?!IN)"],
        latex: " \\not "
      },
      {
        regex: ["ni", "Ni", "NI"],
        latex: " \\ni "
      },
      {
        regex: ["owns", "Owns", "OWNS"],
        latex: " \\owns "
      },
      {
        regex: ["notin", "Notin", "NOTIN"],
        latex: " \\not \\in "
      },
      {
        regex: ["nin", "Nin", "NIN"],
        latex: " \\not \\in "
      },
      {
        regex: ["notni", "Notni", "NOTNI"],
        latex: " \\not \\ni "
      },
      {
        regex: ["leq", "Leq", "LEQ"],
        latex: " \\leq "
      },
      {
        regex: ["le", "Le", "LE"],
        latex: " \\le "
      },
      {
        regex: "<=",
        latex: " \\leqq ",
        alphabetic: false
      },
      {
        regex: ["geq", "Geq", "GEQ"],
        latex: " \\geq "
      },
      {
        regex: ["ge", "Ge", "GE"],
        latex: " \\ge "
      },
      {
        regex: ">=",
        latex: " \\geqq ",
        alphabetic: false
      },
      {
        regex: "(?<![>\\-])(?:(?<!\\s)>|>(?!\\s))(?![=>])",
        latex: " > ",
        alphabetic: false
      },
      {
        regex: "(?<![s<])(?:(?<!\\s)<|<(?!\\s))(?![<=])",
        latex: " < ",
        alphabetic: false
      },

      {
        regex: ["oplus", "Oplus", "OPLUS"],
        latex: " \\oplus "
      },
      {
        regex: ["ominus", "Ominus", "OMINUS"],
        latex: " \\ominus "
      },
      {
        regex: ["otimes", "Otimes", "OTIMES"],
        latex: " \\otimes "
      },
      {
        regex: ["odot", "Odot", "ODOT"],
        latex: " \\odot "
      },
      {
        regex: ["oslash", "Oslash", "OSLASH"],
        latex: " \\oslash "
      },
      {
        regex: ["lor", "Lor", "LOR"],
        latex: " \\lor "
      },
      {
        regex: ["vee", "Vee", "VEE"],
        latex: " \\vee "
      },
      {
        regex: ["bigvee", "Bigvee", "BIGVEE"],
        latex: " \\bigvee "
      },
      {
        regex: ["land", "Land", "LAND"],
        latex: " \\land "
      },
      {
        regex: ["wedge", "Wedge", "WEDGE"],
        latex: " \\wedge "
      },
      {
        regex: ["bigwedge", "Bigwedge", "BIGWEDGE"],
        latex: " \\bigwedge "
      },
      {
        regex: "(?<!<)<<(?!<)",
        latex: " \\ll ",
        alphabetic: false
      },
      {
        regex: "(?<!>)>>(?!>)",
        latex: " \\gg ",
        alphabetic: false
      },
      {
        regex: "<<<",
        latex: " \\lll ",
        alphabetic: false
      },
      {
        regex: ["lll", "Lll", "LLL"],
        latex: " \\lll "
      },
      {
        regex: ">>>",
        latex: " \\ggg ",
        alphabetic: false
      },
      {
        regex: "ggg",
        latex: " \\ggg "
      },
      {
        regex: ["prec", "PREC"],
        latex: " \\prec "
      },
      {
        regex: ["succ", "Succ", "SUCC"],
        latex: " \\succ "
      },


      {
        regex: "\\+\\-",
        latex: " \\pm "
      },
      {
        regex: ["plusminus", "Plusminus", "PLUSMINUS"],
        latex: " \\pm "
      },
      {
        regex: "\\-\\+",
        latex: " \\mp "
      },
      {
        regex: ["minusplus", "Minusplus", "MINUSPLUS"],
        latex: " \\mp "
      },
      {
        regex: ["dsum", "Dsum", "DSUM"],
        latex: " \\dotplus "
      },
      {
        regex: ["times", "Times", "TIMES"],
        latex: " \\times "
      },
      {
        regex: ["divide", "Divide", "DIVIDE"],
        latex: " \\div "
      },
      {
        regex: ["div", "Div", "DIV"],
        latex: " \\div "
      },
      {
        regex: ["circ", "Circ", "CIRC"],
        latex: " \\circ "
      },
      {
        regex: ["bullet", "Bullet", "BULLET"],
        latex: " \\bullet "
      },
      {
        regex: ["Deg", "DEG"],
        latex: " \\,^{\\circ} "
      },
      {
        regex: ["ast", "Ast", "AST"],
        latex: " \\ast "
      },
      {
        regex: ["star", "Star", "STAR"],
        latex: " \\star "
      },
      {
        regex: ["bigcirc", "Bigcirc", "BIGCIRC"],
        latex: " \\bigcirc "
      },
      {
        regex: ["emptyset", "Emptyset", "EMPTYSET"],
        latex: " \\emptyset "
      },
      {
        regex: ["therefore", "Therefore", "THEREFORE"],
        latex: " \\therefore "
      },
      {
        regex: ["because", "Because", "BECAUSE"],
        latex: " \\because "
      },
      {
        regex: ["exists?", "Exists?", "EXISTS?"],
        latex: " \\exists "
      },
      {
        regex: ["ne", "Ne", "NE"],
        latex: " \\ne "
      },
      {
        regex: "!=",
        latex: " \\ne ",
        alphabetic: false
      },
      {
        regex: ["neq", "Neq", "NEQ"],
        latex: " \\neq "
      },
      {
        regex: ["doteq", "Doteq", "DOTEQ"],
        latex: " \\doteq "
      },
      {
        regex: ["image", "Image"],
        latex: " \\fallingdotseq "
      },
      {
        regex: ["reimage", "Reimage", "REIMAGE"],
        latex: " \\risingdotseq "
      },
      {
        regex: ["sim", "Sim", "SIM"],
        latex: " \\backsim "
      },
      {
        regex: "∾",
        latex: " \\backsim ",
        alphabetic: false
      },
      {
        regex: "\\xf3\\xb0\\x81\\x80",
        latex: " \\backsim ",
        alphabetic: false
      },
      {
        regex: ["simeq", "Simeq", "SIMEQ"],
        latex: " \\simeq "
      },
      {
        regex: ["approx", "Approx", "APPROX"],
        latex: " \\approx "
      },
      {
        regex: ["cong", "Cong", "CONG"],
        latex: " \\cong "
      },
      {
        regex: ["equiv", "Equiv", "EQUIV"],
        latex: " \\equiv "
      },
      {
        regex: "==",
        latex: " \\equiv ",
        alphabetic: false
      },
      {
        regex: ["asymp", "Asymp", "ASYMP"],
        latex: " \\asymp "
      },
      {
        regex: ["iso", "Iso", "ISO"],
        latex: " \\Bumpeq "
      },
      {
        regex: ["diamond", "Diamond", "DIAMOND"],
        latex: " \\diamond "
      },
      {
        regex: ["Forall", "FORALL"],
        latex: " \\forall "
      },
      {
        regex: "prime",
        latex: " ' "
      },
      {
        regex: ["partial", "Partial", "PARTIAL"],
        latex: " \\partial "
      },
      {
        regex: ["infty", "Infty", "INFTY"],
        latex: " \\infty "
      },
      {
        regex: ["inf", "Inf", "INF"],
        latex: " \\infty "
      },
      {
        regex: ["infinity", "Infinity", "INFINITY"],
        latex: " \\infty "
      },
      {
        regex: ["LNOT"],
        latex: " \\lnot "
      },
      {
        regex: ["neg", "Neg", "NEG"],
        latex: " \\neg "
      },
      {
        regex: ["propto", "PROPTO"],
        latex: " \\propto "
      },
      {
        regex: ["xor", "Xor", "XOR"],
        latex: " \\veebar "
      },
      {
        regex: ["dagger", "Dagger", "DAGGER"],
        latex: " \\dagger "
      },
      {
        regex: ["ddagger", "Ddagger", "DDAGGER"],
        latex: " \\ddagger "
      },
      {
        regex: ["parallel", "Parallel", "PARALLEL"],
        latex: " \\parallel "
      },


      {
        regex: ["larrow", "leftarrow"],
        latex: " \\leftarrow "
      },
      {
        regex: ["Leftarrow", "LEFTARROW", "LARROW", "Larrow"],
        latex: " \\Leftarrow "
      },
      {
        regex: ["rarrow", "rightarrow"],
        latex: " \\rightarrow "
      },
      {
        regex: ["Rightarrow", "RIGHTARROW", "RARROW", "Rarrow"],
        latex: " \\Rightarrow "
      },
      {
        regex: "uparrow",
        latex: " \\uparrow "
      },
      {
        regex: ["Uparrow", "UPARROW"],
        latex: " \\Uparrow "
      },
      {
        regex: "downarrow",
        latex: " \\downarrow "
      },
      {
        regex: ["Downarrow", "DOWNARROW"],
        latex: " \\Downarrow "
      },
      {
        regex: "udarrow",
        latex: " \\updownarrow "
      },
      {
        regex: ["Udarrow", "UDARROW"],
        latex: " \\Updownarrow "
      },
      {
        regex: "lrarrow",
        latex: " \\leftrightarrow "
      },
      {
        regex: ["Lrarrow", "LRARROW"],
        latex: " \\Leftrightarrow "
      },
      {
        regex: ["nwarrow", "Nwarrow", "NWARROW"],
        latex: " \\nwarrow "
      },
      {
        regex: ["searrow", "Searrow", "SEARROW"],
        latex: " \\searrow "
      },
      {
        regex: ["nearrow", "Nearrow", "NEARROW"],
        latex: " \\nearrow "
      },
      {
        regex: ["swarrow", "Swarrow", "SWARROW"],
        latex: " \\swarrow "
      },
      {
        regex: ["hookleft", "Hookleft", "HOOKLEFT"],
        latex: " \\hookleftarrow "
      },
      {
        regex: ["hookright", "Hookright", "HOOKRIGHT"],
        latex: " \\hookrightarrow "
      },
      {
        regex: ["mapsto", "Mapsto", "MAPSTO"],
        latex: " \\mapsto "
      },
      {
        regex: ["Vert", "VERT"],
        latex: " \\Vert "
      },
      {
        regex: "vert",
        latex: " \\vert "
      },


      {
        regex: ["backslash", "Backslash", "BACKSLASH"],
        latex: " \\backslash "
      },
      {
        regex: ["cdot(?!s)", "Cdot(?!s)", "CDOT(?!S)"],
        latex: " \\cdot "
      },
      {
        regex: ["cdots", "Cdots", "CDOTS"],
        latex: " \\cdots "
      },
      {
        regex: ["ldots", "Ldots", "LDOTS"],
        latex: " \\ldots "
      },
      {
        regex: ["vdots", "Vdots", "VDOTS"],
        latex: " \\vdots "
      },
      {
        regex: ["ddots", "Ddots", "DDOTS"],
        latex: " \\ddots "
      },
      {
        regex: ["triangle(?![dlr])", "Triangle(?![dlr])", "TRIANGLE(?![DLR])"],
        latex: " \\triangle "
      },
      {
        regex: ["triangled", "Triangled", "TRIANGLED"],
        latex: " \\triangledown "
      },
      {
        regex: ["trianglel", "Trianglel", "TRIANGLEL"],
        latex: " \\triangleleft "
      },
      {
        regex: ["triangler", "Triangler", "TRIANGLER"],
        latex: " \\triangleright "
      },
      {
        regex: ["nabla", "Nabla", "NABLA"],
        latex: " \\nabla "
      },
      {
        regex: ["angle", "Angle", "ANGLE"],
        latex: " \\angle "
      },
      {
        regex: ["langle", "Langle", "LANGLE"],
        latex: " \\langle "
      },
      {
        regex: ["rangle", "Rangle", "RANGLE"],
        latex: " \\rangle "
      },
      {
        regex: ["msangle", "Msangle", "MSANGLE"],
        latex: " \\measuredangle "
      },
      {
        regex: ["sangle", "Sangle", "SANGLE"],
        latex: " \\sphericalangle "
      },
      {
        regex: ["vdash", "Vdash", "VDASH"],
        latex: " \\vdash "
      },
      {
        regex: ["hright", "Hright", "HRIGHT"],
        latex: " \\vdash "
      },
      {
        regex: ["dashv", "Dashv", "DASHV"],
        latex: " \\dashv "
      },
      {
        regex: ["hleft", "Hleft", "HLEFT"],
        latex: " \\dashv "
      },
      {
        regex: ["bot", "Bot", "BOT"],
        latex: " \\bot "
      },
      {
        regex: ["top", "Top", "TOP"],
        latex: " \\top "
      },
      {
        regex: ["Models", "MODELS"],
        latex: " \\models "
      },
      {
        regex: ["laplace", "Laplace", "LAPLACE"],
        latex: " \\mathscr {L} "
      },
      {
        regex: ["centigrade", "Centigrade", "CENTIGRADE"],
        latex: " \\,^{\\circ}\\mathrm {C} "
      },
      {
        regex: ["fahrenheit", "Fahrenheit", "FAHRENHEIT"],
        latex: " \\,^{\\circ}\\mathrm {F} "
      },
      {
        regex: ["amalg", "Amalg", "AMALG"],
        latex: " \\amalg "
      },
      {
        regex: ["lfloor", "Lfloor", "LFLOOR"],
        latex: " \\lfloor "
      },
      {
        regex: ["rfloor", "Rfloor", "RFLOOR"],
        latex: " \\rfloor "
      },
      {
        regex: ["lceil", "Lceil", "LCEIL"],
        latex: " \\lceil "
      },
      {
        regex: ["rceil", "Rceil", "RCEIL"],
        latex: " \\rceil "
      },
      {
        regex: "->",
        latex: " \\to ",
        alphabetic: false
      }
    ]

    RESERVED_WORD = [
      {
        regex: "(?<!mathrm\\s{)sin(?!h)",
        latex: " \\mathrm {sin} "
      },
      {
        regex: "(?<!mathrm\\s{)cos(?!ec|h)",
        latex: " \\mathrm {cos} "
      },
      {
        regex: "(?<!mathrm\\s{)coth",
        latex: " \\mathrm {coth} "
      },
      {
        regex: "(?<!mathrm\\s{)log",
        latex: " \\mathrm {log} "
      },
      {
        regex: "(?<!mathrm\\s{)tan(?!h)",
        latex: " \\mathrm {tan} "
      },
      {
        regex: "(?<!mathrm\\s{)cot(?!h)",
        latex: " \\mathrm {cot} "
      },
      {
        regex: "(?<!mathrm\\s{)ln(?!ot)",
        latex: " \\mathrm {ln} "
      },
      {
        regex: "(?<!mathrm\\s{)lg",
        latex: " \\mathrm {lg} "
      },
      {
        regex: "(?<!mathrm\\s{)sec",
        latex: " \\mathrm {sec} "
      },
      {
        regex: "(?<!mathrm\\s{)cosec",
        latex: " \\mathrm {cosec} "
      },
      {
        regex: "(?<!mathrm\\s{)max",
        latex: " \\mathrm {max} "
      },
      {
        regex: "(?<!mathrm\\s{)min",
        latex: " \\mathrm {min} "
      },
      {
        regex: "(?<!mathrm\\s{)csc",
        latex: " \\mathrm {csc} "
      },
      {
        regex: "(?<!mathrm\\s{)arcsin",
        latex: " \\mathrm {arcsin} "
      },
      {
        regex: "(?<!mathrm\\s{)lim",
        latex: " \\mathrm {lim} "
      },
      {
        regex: "(?<!mathrm\\s{)Lim",
        latex: " \\mathrm {Lim} "
      },
      {
        regex: "(?<!mathrm\\s{)arccos",
        latex: " \\mathrm {arccos} "
      },
      {
        regex: "(?<!mathrm\\s{)arctan",
        latex: " \\mathrm {arctan} "
      },
      {
        regex: "(?<!mathrm\\s{)exp",
        latex: " \\mathrm {exp} "
      },
      {
        regex: "(?<!mathrm\\s{)Exp",
        latex: " \\mathrm {Exp} "
      },
      {
        regex: "(?<!mathrm\\s{)arc(?!h|sin|cos|tan)",
        latex: " \\mathrm {arc} "
      },
      {
        regex: "(?<!mathrm\\s{)sinh",
        latex: " \\mathrm {sinh} "
      },
      {
        regex: "(?<!mathrm\\s{)det",
        latex: " \\mathrm {det} "
      },
      {
        regex: "(?<!mathrm\\s{)gcd",
        latex: " \\mathrm {gcd} "
      },
      {
        regex: "(?<!mathrm\\s{)cosh",
        latex: " \\mathrm {cosh} "
      },
      {
        regex: "(?<!mathrm\\s{)tanh",
        latex: " \\mathrm {tanh} "
      },
      {
        regex: "(?<!mathrm\\s{)mod",
        latex: " \\mathrm {mod} "
      },

      {
        regex: "(?<!mathrm\\s{)if",
        latex: " \\mathrm {if} "
      },
      {
        regex: "(?<!mathrm\\s{)for",
        latex: " \\mathrm {for} "
      },
      {
        regex: "(?<!mathrm\\s{)and",
        latex: " \\mathrm {and} "
      },
      {
        regex: "(?<!mathrm\\s{)hom",
        latex: " \\mathrm {hom} "
      },
      {
        regex: "(?<!mathrm\\s{)ker",
        latex: " \\mathrm {ker} "
      },
      {
        regex: "(?<!mathrm\\s{)deg",
        latex: " \\mathrm {deg} "
      },
      {
        regex: "(?<!mathrm\\s{)arg",
        latex: " \\mathrm {arg} "
      },
      {
        regex: "(?<!mathrm\\s{)dim",
        latex: " \\mathrm {dim} "
      },
      {
        regex: "(?<!mathrm\\s{)Pr",
        latex: " \\mathrm {Pr} "
      } 
    ]

    def rule_regex(rule)
      regexes = []
      if rule[:regex].class == Array
        regexes = rule[:regex]
      else
        regexes << rule[:regex]
      end

      is_alphabetic = rule[:alphabetic].nil? ? true : rule[:alphabetic]
      if is_alphabetic
        return %r((?<![a-zA-Z\\])(#{regexes.join('|')}))
      else
        return %r((?<![\\])(#{regexes.join('|')}))
      end
    end
  end
end
