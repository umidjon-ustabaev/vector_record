# frozen_string_literal: true

module VectorRecord
  module Plugins
    module Core
      # Instance methods mixed into {VectorRecord::Pipeline::Embeddings}.
      module EmbeddingsMethods
        # Generates embeddings for the loaded documents.
        #
        # @return [void]
        def embeddings
          print("Embeddings...")
        end
      end
    end
  end
end
