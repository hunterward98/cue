# frozen_string_literal: true

module RuboCop
  module Cop
    module Cue
      # Master plan: mobile-first. Every system-spec example must exercise
      # the viewport matrix via with_each_viewport (spec/support/viewports.rb)
      # so flows are proven at 375x812 and 1280x800, not just desktop.
      #
      # A genuinely viewport-independent spec may disable this cop inline
      # with a justification comment - that keeps exceptions visible in
      # review instead of silently accumulating.
      #
      # @example
      #   # bad
      #   it "shows the board" do
      #     visit board_path
      #   end
      #
      #   # good
      #   it "shows the board" do
      #     with_each_viewport do |viewport|
      #       visit board_path
      #     end
      #   end
      class SystemSpecViewportMatrix < Base
        MSG = "System-spec examples must run the viewport matrix: wrap the " \
              "flow in `with_each_viewport` (see spec/support/viewports.rb)."

        RESTRICT_ON_SEND = %i[it scenario example specify].freeze

        def on_send(node)
          block = node.block_node
          return unless block
          return if block.each_descendant(:send).any? { |send| send.method?(:with_each_viewport) }

          add_offense(node)
        end
      end
    end
  end
end
