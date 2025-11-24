# frozen_string_literal: true

require "eq_to_latex/syntax"
require "eq_to_latex/processor"

module EqToLatex
  # Converts Korean Hangul equation script to LaTeX syntax
  class Converter
    include Syntax

    # Regex for matching terms in equations (left and right sides of operators)
    TERM_REGEX = "(?<%<name>s>{(?>[^{}]+|(?:\\g<%<name>s>))*}|(?:[^{}\\s`]{0,9}))"
    LEFT_TERM_REGEX = "(?:[^{}\\s`]{9})*?\\K#{TERM_REGEX}"

    def initialize
      @processor = Processor.new
      @rules = build_sorted_rules
    end

    # Convert Hangul equation script to LaTeX
    #
    # @param script [String] The equation in Hangul format
    # @param dollar_sign [Boolean] Wrap output in $ signs for inline math
    # @param display_mode [Boolean] Add \displaystyle to sum/int operators
    # @return [String] LaTeX formatted equation
    def convert(script, dollar_sign: true, display_mode: false)
      result = @processor.pre_process(script)

      result = apply_keyword_commands(result)
      result = apply_unary_commands(result)
      result = apply_block_commands(result)
      result = apply_sqrt(result)
      result = apply_fractions(result)
      result = apply_symbol_replacements(result)
      result = apply_displaystyle(result) if display_mode

      result = @processor.post_process(result)
      dollar_sign ? "$#{result}$" : result
    end

    private

    def build_sorted_rules
      {
        keywords: sort_by_length(KEYWORD_COMMANDS),
        unary: DEFAULT_COMMANDS,
        blocks: BLOCK_COMMANDS,
        symbols: sort_by_length(META + SYMBOL + RESERVED_WORD)
      }
    end

    def sort_by_length(rules)
      rules.sort_by { |rule| -regex_length(rule[:regex]) }
    end

    def regex_length(regex)
      case regex
      when Array then regex.map(&:length).max
      else regex.to_s.length
      end
    end

    # Apply keyword commands (no parameters, simple replacements like sum, int)
    def apply_keyword_commands(script)
      replace_until_stable(script, @rules[:keywords])
    end

    # Apply unary commands (one right-hand parameter like sub, sup, bar)
    def apply_unary_commands(script)
      @rules[:unary].each do |command|
        script = apply_unary_command(script, command)
      end
      script
    end

    def apply_unary_command(script, command)
      term_regex = build_term_regex("rt")
      pattern = /(?<![a-zA-Z\\])(?i:#{command[:regex]})\s*#{term_regex}/

      while (match = script.match(pattern))
        term = strip_braces(match["rt"])
        script = script.sub(pattern, " #{command[:latex]} {#{term}} ")
      end
      script
    end

    # Apply block commands (matrix, cases - use \begin{} \end{})
    def apply_block_commands(script)
      @rules[:blocks].each do |command|
        script = apply_block_command(script, command)
      end
      script
    end

    def apply_block_command(script, command)
      pattern = /(?<![a-zA-Z])(?i:#{command[:regex]})\s*(?<content>{(?>[^{}]+|(?:\g<content>))*})/

      while (match = script.match(pattern))
        content = strip_braces(match["content"])
        replacement = " \\begin{#{command[:latex]}} #{content} \\end{#{command[:latex]}} "
        script = script.sub(pattern) { replacement }
      end
      script
    end

    # Apply sqrt/root conversion: sqrt A => \sqrt{A}, sqrt A of B => \sqrt[A]{B}
    def apply_sqrt(script)
      base = build_term_regex("base")
      index = build_term_regex("index")
      pattern = /(?<!\\)(?i:sqrt|root)\s*#{base}(\s*(?i:of)\s*#{index})?/

      while (match = script.match(pattern))
        base_term = strip_braces(match["base"])
        index_term = match["index"] ? strip_braces(match["index"]) : nil

        replacement = if index_term
                        " \\sqrt [#{base_term}]{#{index_term}} "
                      else
                        " \\sqrt {#{base_term}} "
                      end
        script = script.sub(pattern) { replacement }
      end
      script
    end

    # Apply fraction conversion: A over B => \dfrac{A}{B}
    def apply_fractions(script)
      left = build_left_term_regex("lt")
      right = build_term_regex("rt")
      pattern = /#{left}\s*(?<!\\)(?i:over(?!line)|atop)\s*#{right}/

      while (match = script.match(pattern))
        left_term = strip_braces(match["lt"])
        right_term = strip_braces(match["rt"])
        script = script.sub(pattern, " \\dfrac {#{left_term}}{#{right_term}} ")
      end
      script
    end

    # Apply symbol and reserved word replacements
    def apply_symbol_replacements(script)
      replace_until_stable(script, @rules[:symbols])
    end

    # Add \displaystyle to large operators
    def apply_displaystyle(script)
      script
        .gsub(/\\sum/, "\\displaystyle \\sum")
        .gsub(/\\int/, "\\displaystyle \\int")
        .gsub(/\\oint/, "\\displaystyle \\oint")
    end

    # Keep applying replacements until no more matches
    def replace_until_stable(script, rules)
      loop do
        changed = false
        rules.each do |rule|
          pattern = build_rule_regex(rule)
          new_script = script.gsub(pattern, rule[:latex])
          if new_script != script
            script = new_script
            changed = true
          end
        end
        break unless changed
      end
      script
    end

    def build_rule_regex(rule)
      patterns = Array(rule[:regex])
      alphabetic = rule[:alphabetic] != false

      prefix = alphabetic ? '(?<![a-zA-Z\\\\])' : '(?<![\\\\])'
      Regexp.new("#{prefix}(#{patterns.join('|')})")
    end

    def build_term_regex(name)
      format(TERM_REGEX, name: name)
    end

    def build_left_term_regex(name)
      format(LEFT_TERM_REGEX, name: name)
    end

    def strip_braces(term)
      return "" if term.nil?

      term.sub(/\A\{/, "").sub(/\}\z/, "")
    end
  end
end
