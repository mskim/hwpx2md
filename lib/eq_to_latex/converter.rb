require 'json'
require 'eq_to_latex/syntax'
require 'eq_to_latex/processor'

module EqToLatex
  # 한글 수식스크립트를 LaTeX 문법으로 변환
  class Converter
    include Syntax

    # 명령어에 사용되는 좌, 우항 정규표현식
    LEFT_TERM_REGEX = "(?:[^{}\\s`]{9})*?\\K(?<%s>{(?>[^{}]+|(?:\\g<%s>))*}|(?:[^{}\\s`]{0,9}))"
    RIGHT_TERM_REGEX = "(?<%s>{(?>[^{}]+|(?:\\g<%s>))*}|(?:[^{}\\s`]{0,9}))"

    def initialize
      @processor = Processor.new
      @keyword_commands = KEYWORD_COMMANDS
      @default_commands = DEFAULT_COMMANDS
      @block_commands = BLOCK_COMMANDS

      @meta = META.sort_by { |hash| -1 * hash[:regex].inspect.length }
      @symbols = SYMBOL.sort_by { |hash| -1 * hash[:regex].inspect.length }
      @reserved_words = RESERVED_WORD.sort_by { |hash| -1 * hash[:regex].inspect.length }
    end

    def convert(script, dollar_sign: true, display_mode: false)
      # Data pre processing
      result = @processor.pre_process(script)
      # 파라미터가 없는 명령어
      result = replace_keyword_commands(result)
      # 1개의 우항을 가지는 명령어
      result = replace_default_commands(result)
      # 행렬, 케이스등 블록 명령어
      #   cases {...} => \begin{cases}...\end{cases}
      #   dmatrix {...} => \begin{vmatrix}...\end{vmatrix}
      #   bmatrix {...} => \begin{Bmatrix}...\end{Bmatrix}
      #   pmatrix {...} => \begin{pmatrix}...\end{pmatrix}
      #   matrix {...} => \begin{matrix}...\end{matrix}
      result = replace_block_commands(result)

      # 특수 형태의 명령어 치환
      # Case 1. 루트 변환
      #   sqrt A => \sqrt {A}
      #   sqrt A of B => \sqrt [A]{B}
      # Case 2. 분수 변환
      #   A over B => \dfrac {A}{B}
      result = replace_sqrt(result) # Case 1
      result = replace_fractions(result) # Case 2

      # 단순 치환 키워드
      result = replace_keywords(result)

      # 전체 수식에 디스플레이 스타일 적용
      result = decorate_displaystyle(result) if display_mode

      # Data post processing
      result = @processor.post_process(result)

      # Math mode
      result = "$#{result}$" if dollar_sign

      return result
    end

    private

    def replace_keyword_commands(script)
      commands = @keyword_commands
      matched_count = 0
      
      # 1star(2star(3starcdotsstar(99star100))cdots)
      # 위와 같은 경우 이중 루프 cdots 부터 매치되기 시작하면 star 때문에
      # 제대로 변환되지 않음.
      # 그러므로 전체 키워드를 검사하는 루프(loop 2)를
      # 이중 루프로 변환이 완료될 때 까지 반복함(loop 1)
      # 속도는 느려지겠지만 대안을 찾을 때 까지 이대로 사용하려고 함
      loop do # loop 1
        matched_count = 0
        commands.each do |command|
          command_regex = rule_regex(command)
          before_script = script
          script = script.gsub(command_regex, command[:latex])
          while before_script != script # loop 2
            matched_count += 1
            before_script = script
            script = script.gsub(command_regex, command[:latex])
          end
        end
        break if matched_count == 0
      end

      return script
    end

    def replace_default_commands(script)
      right_term_group_name = "rt"

      @default_commands.each do |command|
        right_term_regex = RIGHT_TERM_REGEX % [right_term_group_name, right_term_group_name]
        command_regex = %r((?<![a-zA-Z\\])(?i:#{command[:regex]})\s*#{right_term_regex})

        match_data = script.match(command_regex)
        while match_data
          right_term = remove_curly_brackets(match_data[right_term_group_name])
          script = script.sub(command_regex, " #{command[:latex]} {%{#{right_term_group_name}}} " % {
            "#{right_term_group_name}".to_sym => right_term
          })
          match_data = script.match(command_regex)
        end
      end

      return script
    end

    def replace_block_commands(script)
      @block_commands.each do |command|
        command_regex = %r((?<![a-zA-Z])(?i:#{command[:regex]})\s*(?<block_content>{(?>[^{}]+|(?:\g<block_content>))*}))

        match_data = script.match(command_regex)
        while match_data
          # 시작, 끝 중괄호 제거
          block_content = remove_curly_brackets(match_data['block_content'])
          # sub 메서드에 블록 문법을 사용한 이유:
          #   gsub, sub에서 백슬래시 문제
          script = script.sub(command_regex) { " \\begin{#{command[:latex]}} %s \\end{#{command[:latex]}} " % block_content }
          match_data = script.match(command_regex)
        end
      end

      return script
    end

    def replace_keywords(script)
      keywords = @meta + @symbols + @reserved_words
      matched_count = 0
      
      # 1star(2star(3starcdotsstar(99star100))cdots)
      # 위와 같은 경우 이중 루프 cdots 부터 매치되기 시작하면 star 때문에
      # 제대로 변환되지 않음.
      # 그러므로 전체 키워드를 검사하는 루프(loop 2)를
      # 이중 루프로 변환이 완료될 때 까지 반복함(loop 1)
      # 속도는 느려지겠지만 대안을 찾을 때 까지 이대로 사용하려고 함
      loop do # loop 1
        matched_count = 0
        keywords.each do |keyword|
          keyword_regex = rule_regex(keyword)
          before_script = script
          script = script.gsub(keyword_regex, keyword[:latex])
          while before_script != script # loop 2
            matched_count += 1
            before_script = script
            script = script.gsub(keyword_regex, keyword[:latex])
          end
        end
        break if matched_count == 0
      end

      return script
    end

    def replace_fractions(script)
      left_term_group_name = "lt"
      right_term_group_name = "rt"
      left_term_regex = LEFT_TERM_REGEX % [left_term_group_name, left_term_group_name]
      right_term_regex = RIGHT_TERM_REGEX % [right_term_group_name, right_term_group_name]
      fraction_regex = %r(#{left_term_regex}\s*(?<!\\)(?i:over(?!line)|atop)\s*#{right_term_regex})

      match_data = script.match(fraction_regex)
      while match_data
        matched_groups = Hash[match_data.names.map(&:to_sym).zip(
          match_data.captures.map {|term| remove_curly_brackets(term) }
        )]
        script = script.sub(fraction_regex, " \\dfrac {%{lt}}{%{rt}} " % matched_groups)
        match_data = script.match(fraction_regex)
      end

      return script
    end

    def replace_sqrt(script)
      right_term_name1 = 'rt1'
      right_term_name2 = 'rt2'
      right_term_regex1 = RIGHT_TERM_REGEX % [right_term_name1, right_term_name1]
      right_term_regex2 = RIGHT_TERM_REGEX % [right_term_name2, right_term_name2]
      sqrt_regex = %r((?<!\\)(?i:sqrt|root)\s*#{right_term_regex1}(\s*(?i:of)\s*#{right_term_regex2})?)

      match_data = script.match(sqrt_regex)
      while match_data
        has_right_term2 = !!match_data[right_term_name2]

        # 첫 번째 항 중괄호 제거
        right_term_content1 = remove_curly_brackets(match_data[right_term_name1])

        if has_right_term2
          # 두 번째 항 중괄호 제거
          right_term_content2 = remove_curly_brackets(match_data[right_term_name2])
        end

        script = script.sub(sqrt_regex) do
          if has_right_term2
            " \\sqrt [%s]{%s} " % [right_term_content1, right_term_content2]
          else
            " \\sqrt {%s} " % right_term_content1
          end
        end
        match_data = script.match(sqrt_regex)
      end

      return script
    end

    def decorate_displaystyle(script)
      script = script.gsub(/\\sum/, "\\displaystyle \\sum")
      script = script.gsub(/\\int/, "\\displaystyle \\int")
      script = script.gsub(/\\oint/, "\\displaystyle \\oint")

      return script
    end

    def remove_curly_brackets(term)
      return term.gsub(/(^{)|(}$)/, '')
    end
  end
end
