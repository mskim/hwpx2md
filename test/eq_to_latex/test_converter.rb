# frozen_string_literal: true

require_relative "../test_helper"

describe "EqToLatex::Converter" do
  before do
    @converter = EqToLatex::Converter.new
  end

  describe "#convert" do
    describe "basic conversion" do
      it "wraps output in dollar signs by default" do
        result = @converter.convert("a")
        assert result.start_with?("$")
        assert result.end_with?("$")
      end

      it "does not wrap in dollar signs when dollar_sign: false" do
        result = @converter.convert("a", dollar_sign: false)
        refute result.start_with?("$")
        refute result.end_with?("$")
      end
    end

    describe "fractions (over)" do
      it "converts simple fraction" do
        result = @converter.convert("a over b", dollar_sign: false)
        assert_includes result, "\\dfrac"
        assert_includes result, "{a}"
        assert_includes result, "{b}"
      end

      it "converts fraction with complex terms" do
        result = @converter.convert("{x+1} over {y-1}", dollar_sign: false)
        assert_includes result, "\\dfrac"
      end
    end

    describe "square roots (sqrt)" do
      it "converts simple sqrt" do
        result = @converter.convert("sqrt a", dollar_sign: false)
        assert_includes result, "\\sqrt"
        assert_includes result, "{a}"
      end

      it "converts sqrt with index (nth root)" do
        result = @converter.convert("sqrt 3 of x", dollar_sign: false)
        assert_includes result, "\\sqrt"
        assert_includes result, "[3]"
        assert_includes result, "{x}"
      end
    end

    describe "subscript and superscript" do
      it "converts subscript (sub)" do
        result = @converter.convert("x sub i", dollar_sign: false)
        assert_includes result, "_"
        assert_includes result, "{i}"
      end

      it "converts superscript (sup)" do
        result = @converter.convert("x sup 2", dollar_sign: false)
        assert_includes result, "^"
        assert_includes result, "{2}"
      end
    end

    describe "Greek letters" do
      it "converts lowercase alpha" do
        result = @converter.convert("alpha", dollar_sign: false)
        assert_includes result, "\\alpha"
      end

      it "converts uppercase Alpha" do
        result = @converter.convert("Alpha", dollar_sign: false)
        assert_includes result, "\\mathit {A}"
      end

      it "converts beta" do
        result = @converter.convert("beta", dollar_sign: false)
        assert_includes result, "\\beta"
      end

      it "converts gamma" do
        result = @converter.convert("gamma", dollar_sign: false)
        assert_includes result, "\\gamma"
      end

      it "converts delta" do
        result = @converter.convert("delta", dollar_sign: false)
        assert_includes result, "\\delta"
      end

      it "converts pi" do
        result = @converter.convert("pi", dollar_sign: false)
        assert_includes result, "\\pi"
      end

      it "converts omega" do
        result = @converter.convert("omega", dollar_sign: false)
        assert_includes result, "\\omega"
      end

      it "converts theta" do
        result = @converter.convert("theta", dollar_sign: false)
        assert_includes result, "\\theta"
      end
    end

    describe "mathematical functions" do
      it "converts sin" do
        result = @converter.convert("sin", dollar_sign: false)
        assert_includes result, "\\mathrm {sin}"
      end

      it "converts cos" do
        result = @converter.convert("cos", dollar_sign: false)
        assert_includes result, "\\mathrm {cos}"
      end

      it "converts tan" do
        result = @converter.convert("tan", dollar_sign: false)
        assert_includes result, "\\mathrm {tan}"
      end

      it "converts log" do
        result = @converter.convert("log", dollar_sign: false)
        assert_includes result, "\\mathrm {log}"
      end

      it "converts ln" do
        result = @converter.convert("ln", dollar_sign: false)
        assert_includes result, "\\mathrm {ln}"
      end

      it "converts lim" do
        result = @converter.convert("lim", dollar_sign: false)
        assert_includes result, "\\mathrm {lim}"
      end

      it "converts exp" do
        result = @converter.convert("exp", dollar_sign: false)
        assert_includes result, "\\mathrm {exp}"
      end
    end

    describe "operators" do
      it "converts sum" do
        result = @converter.convert("sum", dollar_sign: false)
        assert_includes result, "\\sum"
      end

      it "converts int (integral)" do
        result = @converter.convert("int", dollar_sign: false)
        assert_includes result, "\\int"
      end

      it "converts oint (contour integral)" do
        result = @converter.convert("oint", dollar_sign: false)
        assert_includes result, "\\oint"
      end

      it "converts prod" do
        result = @converter.convert("prod", dollar_sign: false)
        assert_includes result, "\\prod"
      end
    end

    describe "comparison operators" do
      it "converts leq" do
        result = @converter.convert("leq", dollar_sign: false)
        assert_includes result, "\\leq"
      end

      it "converts geq" do
        result = @converter.convert("geq", dollar_sign: false)
        assert_includes result, "\\geq"
      end

      it "converts neq" do
        result = @converter.convert("neq", dollar_sign: false)
        assert_includes result, "\\neq"
      end

      it "converts approx" do
        result = @converter.convert("approx", dollar_sign: false)
        assert_includes result, "\\approx"
      end

      it "converts equiv" do
        result = @converter.convert("equiv", dollar_sign: false)
        assert_includes result, "\\equiv"
      end
    end

    describe "set operations" do
      it "converts subset" do
        result = @converter.convert("subset", dollar_sign: false)
        assert_includes result, "\\subset"
      end

      it "converts supset" do
        result = @converter.convert("supset", dollar_sign: false)
        assert_includes result, "\\supset"
      end

      it "converts in" do
        result = @converter.convert("in", dollar_sign: false)
        assert_includes result, "\\in"
      end

      it "converts union" do
        result = @converter.convert("union", dollar_sign: false)
        assert_includes result, "\\bigcup"
      end

      it "converts inter" do
        result = @converter.convert("inter", dollar_sign: false)
        assert_includes result, "\\bigcap"
      end
    end

    describe "arrows" do
      it "converts rightarrow" do
        result = @converter.convert("rightarrow", dollar_sign: false)
        assert_includes result, "\\rightarrow"
      end

      it "converts leftarrow" do
        result = @converter.convert("leftarrow", dollar_sign: false)
        assert_includes result, "\\leftarrow"
      end

      it "converts Rightarrow (double)" do
        result = @converter.convert("Rightarrow", dollar_sign: false)
        assert_includes result, "\\Rightarrow"
      end

      it "converts ->" do
        result = @converter.convert("->", dollar_sign: false)
        assert_includes result, "\\to"
      end
    end

    describe "special symbols" do
      it "converts infty" do
        result = @converter.convert("infty", dollar_sign: false)
        assert_includes result, "\\infty"
      end

      it "converts partial" do
        result = @converter.convert("partial", dollar_sign: false)
        assert_includes result, "\\partial"
      end

      it "converts nabla" do
        result = @converter.convert("nabla", dollar_sign: false)
        assert_includes result, "\\nabla"
      end

      it "converts emptyset" do
        result = @converter.convert("emptyset", dollar_sign: false)
        assert_includes result, "\\emptyset"
      end

      it "converts cdots" do
        result = @converter.convert("cdots", dollar_sign: false)
        assert_includes result, "\\cdots"
      end

      it "converts ldots" do
        result = @converter.convert("ldots", dollar_sign: false)
        assert_includes result, "\\ldots"
      end
    end

    describe "block commands (matrices)" do
      it "converts matrix" do
        result = @converter.convert("matrix {a # b}", dollar_sign: false)
        assert_includes result, "\\begin{matrix}"
        assert_includes result, "\\end{matrix}"
      end

      it "converts pmatrix (parentheses)" do
        result = @converter.convert("pmatrix {a # b}", dollar_sign: false)
        assert_includes result, "\\begin{pmatrix}"
        assert_includes result, "\\end{pmatrix}"
      end

      it "converts cases" do
        result = @converter.convert("cases {a # b}", dollar_sign: false)
        assert_includes result, "\\begin{cases}"
        assert_includes result, "\\end{cases}"
      end
    end

    describe "decorations" do
      it "converts bar (overline)" do
        result = @converter.convert("bar x", dollar_sign: false)
        assert_includes result, "\\overline"
      end

      it "converts hat" do
        result = @converter.convert("hat x", dollar_sign: false)
        assert_includes result, "\\hat"
      end

      it "converts vec" do
        result = @converter.convert("vec x", dollar_sign: false)
        assert_includes result, "\\vec"
      end

      it "converts tilde" do
        result = @converter.convert("tilde x", dollar_sign: false)
        assert_includes result, "\\tilde"
      end

      it "converts dot" do
        result = @converter.convert("dot x", dollar_sign: false)
        assert_includes result, "\\dot"
      end
    end

    describe "display mode" do
      it "adds displaystyle to sum when display_mode is true" do
        result = @converter.convert("sum", dollar_sign: false, display_mode: true)
        assert_includes result, "\\displaystyle"
      end

      it "adds displaystyle to int when display_mode is true" do
        result = @converter.convert("int", dollar_sign: false, display_mode: true)
        assert_includes result, "\\displaystyle"
      end
    end

    describe "complex expressions" do
      it "converts fraction with greek letters" do
        result = @converter.convert("alpha over beta", dollar_sign: false)
        assert_includes result, "\\dfrac"
        assert_includes result, "\\alpha"
        assert_includes result, "\\beta"
      end

      it "handles plus-minus" do
        result = @converter.convert("+-", dollar_sign: false)
        assert_includes result, "\\pm"
      end

      it "handles times" do
        result = @converter.convert("times", dollar_sign: false)
        assert_includes result, "\\times"
      end
    end
  end
end
