module Hwpx2md
  module Elements
    module Containers
      class MathNode
        include Container
        include Elements::Element
        
        attr_reader :math_format
        attr_reader :latex
        def initialize(node, options={})
          @node = node
          @eqn = @node.text
          @latex = eq2latex(@eqn)
          self
        end

        def eq2latex(eq_string)

        end

      end
    end
  end
end