# frozen_string_literal: true

module VectorRecord
  module Plugins
    module Core
      # Instance methods mixed into {VectorRecord::Pipeline::Loader}.
      module LoaderMethods
        # Loads source data into the pipeline.
        #
        # @return [void]
        def load
          print("Loading...")
        end
      end
    end
  end
end
