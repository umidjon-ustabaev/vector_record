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

    # A lightweight dynamic configuration struct backed by a Hash.
    #
    # Subclasses (or instances used directly) gain arbitrary getter/setter
    # pairs without declaring each attribute explicitly. Useful for ad-hoc
    # config namespaces where the key set is not known ahead of time.
    #
    # @example
    #   cfg = BaseConfig.new
    #   cfg.timeout = 30
    #   cfg.timeout  # => 30
    #   cfg.to_h     # => { timeout: 30 }
    class BaseConfig
      # @param settings [Hash] optional initial key/value pairs
      def initialize(settings = {})
        @settings = settings.transform_keys(&:to_sym)
      end

      # Supports +key+ (getter) and +key=+ (setter) for any symbol name.
      def method_missing(name, *args, &block)
        key = name.to_s.delete_suffix("=").to_sym

        if name.to_s.end_with?("=")
          @settings[key] = args.first
        else
          @settings.fetch(key, nil)
        end
      end

      # @param include_private [Boolean]
      # @return [Boolean]
      def respond_to_missing?(name, include_private = false)
        key = name.to_s.delete_suffix("=").to_sym
        @settings.key?(key) || name.to_s.end_with?("=") || super
      end

      # Returns the underlying settings as a plain Hash.
      #
      # @return [Hash{Symbol => Object}]
      def to_h
        @settings.dup
      end

      # @return [String] JSON representation of the settings hash
      def to_json(*args)
        @settings.to_json(*args)
      end

      # @return [String]
      def to_s
        @settings.to_s
      end

      # @return [String]
      def inspect
        "#<#{self.class.name} #{@settings.inspect}>"
      end
    end

    # Configuration for the embedding provider.
    #
    # @example
    #   config.embeddings.api_token = "sk-..."
    #   config.embeddings.model  = "text-embedding-ada-002"
    class Embeddings < BaseConfig; end

    # Configuration for the vector store backend.
    #
    # @example
    #   config.vector_store.adapter = :pgvector
    #   config.vector_store.options = { connection_string: "postgres://..." }
    class VectorStore < BaseConfig; end

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
