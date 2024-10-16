#
#  Author: osh
#  Created: 2019-05-27
#  Last modified: 2019-05-27

module EqToLatex
  class Processor

    # 수식 문자열 전처리
    def pre_process(script)
      # 족보닷컴 텍스트 제거
      jokbo_regex = %r(from\s*=+\s*(?:족보닷컴[\s\S]*?)=+)
      script = script.gsub(jokbo_regex, "")
      # 2개 이상의 공백을 하나의 공백으로 치환
      script = script.gsub(/\s+/, " ").strip
      # 백슬래시(로만체)를 로만체 명령어로 변환
      script = script.gsub(/^\\| \\/, " \\rm ")
      # 꺽쇠 치환
      script = script.gsub(/&lt;/, "<")
      script = script.gsub(/&gt;/, ">")
      # 위, 아래 첨자 명령어로 변경
      script = script.gsub(/_/, " sub ")
      script = script.gsub(/\^/, " sup ")

      return script
    end

    # 수식 문자열 후처리
    def post_process(script)
      # 2개 이상의 공백을 하나의 공백으로 치환
      script = script.gsub(/\s+/, " ").strip
    end
  end
end
