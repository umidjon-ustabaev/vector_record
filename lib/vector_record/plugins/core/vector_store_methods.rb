# frozen_string_literal: true

module VectorRecord
  module Plugins
    module Core
      # Instance methods mixed into {VectorRecord::Pipeline::VectorStore}.
      module VectorStoreMethods
        # Persists embedded documents to the vector store.
        #
        # @return [void]
        def add_documents
          print("VectorStore...")
        end
      end
    end
  end
end
