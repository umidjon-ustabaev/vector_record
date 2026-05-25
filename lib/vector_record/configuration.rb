# frozen_string_literal: true

require "logger"

module VectorRecord
  # Holds all configuration for the VectorRecord library.
  #
  # Access the singleton via {VectorRecord.configuration} and mutate it
  # through the {VectorRecord.configure} block.
  #
  # @example
  #   VectorRecord.configure do |config|
  #     config.embeddings.provider  = "openai"
  #     config.embeddings.api_token = "sk-..."
  #     config.vector_store.adapter = :pgvector
  #   end
  class Configuration
    # Configuration for the embedding provider.
    #
    # @example
    #   config.embeddings.provider   = "gemini"
    #   config.embeddings.model_name = "models/gemini-embedding-2-preview"
    #   config.embeddings.api_token  = "my-token"
    class Embeddings
      # Supported embedding providers.
      # @return [Array<String>]
      PROVIDERS = %w[gemini openai].freeze

      # @return [String]
      DEFAULT_PROVIDER = "gemini"

      # @return [String]
      DEFAULT_MODEL = "models/gemini-embedding-2-preview"

      # @return [String] the active provider name
      attr_reader :provider

      # @return [String] the model identifier sent to the provider
      attr_reader :model_name

      def initialize
        @provider   = DEFAULT_PROVIDER
        @model_name = DEFAULT_MODEL
      end

      # Sets the embedding provider.
      #
      # @param value [String, Symbol] must be one of {PROVIDERS}
      # @raise [ArgumentError] if the provider is not supported
      # @return [String]
      def provider=(value)
        raise ArgumentError, "Unknown provider: #{value}" unless PROVIDERS.include?(value.to_s)

        @provider = value.to_s
      end

      # @param value [String] model identifier
      # @return [String]
      def model_name=(value)
        @model_name = value.to_s
      end

      # Returns the API token, falling back to the
      # +VECTOR_RECORD_EMBEDDINGS_API_TOKEN+ environment variable when no
      # explicit value has been set.
      #
      # @return [String, nil]
      def api_token
        @api_token || ENV.fetch("VECTOR_RECORD_EMBEDDINGS_API_TOKEN", nil)
      end

      # @param value [String] the API token
      # @return [String]
      def api_token=(value)
        @api_token = value
      end
    end

    # Configuration for the vector store backend.
    #
    # @example
    #   config.vector_store.adapter = :pgvector
    #   config.vector_store.options = { connection_string: "postgres://..." }
    class VectorStore
      # Supported vector store adapters.
      # @return [Array<Symbol>]
      ADAPTERS = %i[pgvector qdrant].freeze

      # @return [Symbol]
      DEFAULT_ADAPTER = :pgvector

      # @return [Symbol] the active adapter
      attr_reader :adapter

      # @return [Hash] adapter-specific options
      attr_reader :options

      def initialize
        @adapter = DEFAULT_ADAPTER
        @options = {}
      end

      # Sets the vector store adapter.
      #
      # @param value [String, Symbol] must be one of {ADAPTERS}
      # @raise [ArgumentError] if the adapter is not supported
      # @return [Symbol]
      def adapter=(value)
        raise ArgumentError, "Unknown adapter: #{value}" unless ADAPTERS.include?(value.to_sym)

        @adapter = value.to_sym
      end

      # Sets adapter-specific options. The hash is duplicated to prevent
      # external mutation.
      #
      # @param hash [Hash]
      # @raise [ArgumentError] if the value is not a Hash
      # @return [Hash]
      def options=(hash)
        raise ArgumentError, "options must be a Hash" unless hash.is_a?(Hash)

        @options = hash.dup
      end
    end

    # @return [Embeddings]
    attr_reader :embeddings

    # @return [VectorStore]
    attr_reader :vector_store

    # @return [Logger]
    attr_reader :logger

    def initialize
      @embeddings = Embeddings.new
      @vector_store = VectorStore.new
      @logger = Logger.new($stdout)
    end
  end
end
