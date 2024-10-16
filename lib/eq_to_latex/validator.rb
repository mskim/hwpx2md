#
#  Author: osh
#  Created: 2019-05-27
#  Last modified: 2019-05-27
require 'eq_to_latex/syntax'

module EqToLatex
  # 한글 수식스크립트를 LaTeX로 변환하기 위한 검증
  class Validator
    include Syntax

    def initialize
      @default_commands = DEFAULT_COMMANDS
    end

    def validate(script)
      errors = []

      # Default Command
      @default_commands.each do |command|
        parameter_bracket_regex = %r((?i:#{rule_regex(command)})\s*(?!{|\s))

        match_data = script.match(parameter_bracket_regex)
        if match_data
          errors << {
            name: :command_parameter_need_bracket,
            message: "명령어 파라미터에 중괄호가 누락되었습니다.",
            detail: script
          }
        end
      end

      # Fraction Command
      parameter_bracket_regex = %r(((?<!\s|})\s*(?i:over|atop))|((?i:over|atop)\s*(?!\s|{)))
      match_data = script.match(parameter_bracket_regex)
      if match_data
        errors << {
          name: :fraction_command_parameter_need_bracket,
          message: "분수 명령어 파라미터에 중괄호가 누락되었습니다.",
          detail: script
        }
      end

      # Sqrt Command
      parameter_bracket_regex = %r(((?i:sqrt|root)\s*([^\s{]+))|((?i:sqrt|root)\s*([^\s]+)\s*of\s*([^\s{])))
      match_data = script.match(parameter_bracket_regex)
      if match_data
        errors << {
          name: :sqrt_command_parameter_need_bracket,
          message: "루트 명령어 파라미터에 중괄호가 누락되었습니다.",
          detail: script
        }
      end


      # General
      open_bracket_regex = /(?<![\\])\s*{/
      close_bracket_regex = /(?<![\\])\s*}/
      open_bracket_count = script.scan(open_bracket_regex).length
      close_bracket_count = script.scan(close_bracket_regex).length

      if open_bracket_count != close_bracket_count
        errors << {
          name: :invalid_bracket_pair,
          message: "중괄호 개수가 맞지 않습니다.",
          detail: script
        }
      end

      open_parentheses_regex = /\s*\(/
      close_parentheses_regex = /\s*\)/
      open_parentheses_count = script.scan(open_parentheses_regex).length
      close_parentheses_count = script.scan(close_parentheses_regex).length

      if open_parentheses_count != close_parentheses_count
        errors << {
          name: :invalid_parentheses_pair,
          message: "소괄호 개수가 맞지 않습니다.",
          detail: script
        }
      end

      return errors
    end
  end
end
