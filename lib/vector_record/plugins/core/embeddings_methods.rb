# frozen_string_literal: true

module VectorRecord
  module Plugins
    module Core
      # Mixin that wires the configured embeddings provider into any class that includes it.
      #
      # When included, {.included} reads the active provider from
      # {VectorRecord.configuration} and delegates to {VectorRecord::Embeddings.load},
      # which requires the provider file and mixes in its +ProviderMethods+.
      # The including class therefore gains the full embedding interface
      # (+embed_text+, +embed_documents+, etc.) without knowing which
      # provider is in use.
      #
      # @example
      #   # config/initializer
      #   VectorRecord.configure { |c| c.embeddings.provider = :open_ai }
      #
      #   class MyEmbedder
      #     include VectorRecord::Plugins::Core::EmbeddingsMethods
      #     # => now has #embed_text, #embed_documents from OpenAIEmbeddings::ProviderMethods
      #   end
      module EmbeddingsMethods
        def embed_documents(_documents)
          raise NotImplementedError, "Embeddings plugins must be included"
        end

        def embed_text(_text)
          raise NotImplementedError, "Embeddings plugins must be included"
        end
      end
    end
  end
end
