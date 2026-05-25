# frozen_string_literal: true

module VectorRecord
  module Plugins
    module Core
      # Instance methods mixed into {VectorRecord::Pipeline::Chunker}.
      module ChunkerMethods
        # Splits documents into smaller chunks suitable for embedding.
        #
        # @return [void]
        def chunk
          print("Chunker...")
        end
      end
    end
  end
end
