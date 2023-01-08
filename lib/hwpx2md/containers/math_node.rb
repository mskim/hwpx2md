module Hwpx2md
  module Elements
    module Containers
      class MathNode
        include Container
        include Elements::Element
        
        attr_reader :math_format

        def initialize(node, options={})
          @node = node
          @math_format = options[:math_format] || :latex
          self
        end

        def eq2latex(eq_string)

        end

      end
    end
  end
end