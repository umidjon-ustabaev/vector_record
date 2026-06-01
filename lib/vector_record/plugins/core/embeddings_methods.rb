# frozen_string_literal: true

require "vector_record/embeddings"

module VectorRecord
  module Plugins
    module Core
      # Instance methods mixed into {VectorRecord::Pipeline::Embeddings}.
      module EmbeddingsMethods
        def self.included(base)
          provider = VectorRecord.configuration.embeddings.provider
          VectorRecord::Embeddings.load(provider, base)
        end
      end
    end
  end
end
