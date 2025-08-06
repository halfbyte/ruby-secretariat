module Secretariat
  module ObjectExtensions
    refine Object do
      # Copied from activesupport/lib/active_support/core_ext/object/blank.rb, line 18
      def blank?
        respond_to?(:empty?) ? !!empty? : !self
      end

      def present?
        !blank?
      end
    end
  end
end