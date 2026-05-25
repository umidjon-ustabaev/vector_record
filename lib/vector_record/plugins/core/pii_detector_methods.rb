# frozen_string_literal: true

module VectorRecord
  module Plugins
    module Core
      # Instance methods mixed into {VectorRecord::Pipeline::PiiDetector}.
      module PiiDetectorMethods
        # Anonymizes personally identifiable information in documents before embedding.
        #
        # @return [void]
        def anonymize
          print("PiiDetector...")
        end
      end
    end
  end
end
