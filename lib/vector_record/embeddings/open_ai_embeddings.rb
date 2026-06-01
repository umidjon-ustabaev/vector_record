# frozen_string_literal: true

require "openai"

module VectorRecord
  module Embeddings
    # Generates embeddings via the OpenAI Embeddings API.
    #
    # @example
    #   embedder = VectorRecord::Embeddings::OpenAIEmbeddings.new(api_key: "sk-...")
    #   embedder.embed_text("Hello world")          # => [0.123, -0.456, ...]
    #   embedder.embed_documents([doc1, doc2])       # => [doc1, doc2] with #embeddings populated
    module OpenAIEmbeddings
      VectorRecord::Embeddings.register_provider(:open_ai, self)
      module ProviderMethods
        # @return [String] OpenAI API key
        attr_reader :api_key

        # @return [String] embedding model name
        attr_reader :model

        # @param config [VectorRecord::Configuration::Embeddings]]
        def initialize(config = VectorRecord.configuration.embeddings)
          api_key = config.api_key || ENV["OPENAI_API_KEY"]

          if api_key.nil?
            raise ArgumentError, "OpenAI API key is required"
          end

          @api_key = api_key
          @model = config.model
        end

        # Returns a memoized OpenAI client.
        #
        # @return [OpenAI::Client]
        def client
          @client ||= OpenAI::Client.new(api_key: api_key)
        end

        # Generates embeddings for each document and assigns them in place.
        #
        # @param documents [Array<Pipeline::Document>] documents whose +page_content+ will be embedded
        # @return [Array<Pipeline::Document>] the same documents with +embeddings+ populated
        def embed_documents(documents)
          response = client.embeddings.create(
            input: documents.map(&:page_content),
            model: model
          )

          response.data.each_with_index do |embedding, index|
            documents[index].embeddings = embedding.embedding
          end

          documents
        end

        # Generates an embedding vector for a single string.
        #
        # @param text [String] the text to embed
        # @return [Array<Float>] the embedding vector
        def embed_text(text)
          response = client.embeddings.create(input: text, model: model)
          response.data.first.embedding
        end
      end
    end
  end
end
