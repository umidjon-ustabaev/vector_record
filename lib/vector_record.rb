# frozen_string_literal: true

require_relative "vector_record/version"
require_relative "vector_record/configuration"

# Top-level namespace for the VectorRecord library.
module VectorRecord
  # Base error class for all VectorRecord exceptions.
  class Error < StandardError; end
  # Represents a single loaded document with its content and provenance.
  Document = Struct.new(:id, :page_content, :source, :metadata, :embeddings, keyword_init: true)

  class << self
    # Returns the global {Configuration} instance, creating it on first call.
    #
    # @return [Configuration]
    def configuration
      @configuration ||= Configuration.new
    end

    # Yields the global {Configuration} instance for mutation.
    #
    # @yieldparam config [Configuration]
    # @return [void]
    #
    # @example
    #   VectorRecord.configure do |config|
    #     config.embeddings.provider  = "openai"
    #     config.vector_store.adapter = :qdrant
    #   end
    def configure
      yield configuration
    end

    # Resets the global configuration to defaults. Primarily useful in tests.
    #
    # @return [Configuration]
    def reset_configuration!
      @configuration = Configuration.new
    end
  end

  # Orchestrates the embedding and storage pipeline.
  #
  # Plugins are registered in {PLUGINS} and must implement the interface
  # defined by their corresponding stage class.
  class Pipeline
    # Registry mapping plugin names to their implementation classes.
    # @return [Hash]
    PLUGINS = {}

    private_constant :PLUGINS

    # @abstract Implement to provide a data loader.
    class Loader; end

    # @abstract Implement to provide an embedding strategy.
    class Embeddings; end

    # @abstract Implement to provide a vector store strategy.
    class VectorStore; end

    # @abstract Implement to provide a text chunking strategy.
    class Chunker; end

    # @abstract Implement to provide PII detection.
    class PiiDetector; end

    # @param name [Symbol]
    # @pram mod [Module]
    def self.register_plugin(name, mod)
      PLUGINS[name] = mod
    end


    # @param mod [Module, Symbol]]
    # @param args [Array]
    #
    # @return [void]
    def self.plugin(mod, ...)
      if mod.is_a?(Symbol)
        require "vector_record/plugins/#{mod}"
        mod = PLUGINS.fetch(mod)
      end

      mod.before_load(self, ...) if mod.respond_to?(:before_load)

      if defined?(mod::LoaderMethods)
        self::Loader.include(mod::LoaderMethods)
      end

      if defined?(mod::EmbeddingsMethods)
        self::Embeddings.include(mod::EmbeddingsMethods)
      end

      if defined?(mod::VectorStoreMethods)
        self::VectorStore.include(mod::VectorStoreMethods)
      end

      if defined?(mod::ChunkerMethods)
        self::Chunker.include(mod::ChunkerMethods)
      end

      if defined?(mod::PiiDetectorMethods)
        self::PiiDetector.include(mod::PiiDetectorMethods)
      end

      if defined?(mod::LoaderClassMethods)
        self::Loader.extend(mod::LoaderClassMethods)
      end

      if defined?(mod::EmbeddingsClassMethods)
        self::Embeddings.extend(mod::EmbeddingsClassMethods)
      end

      if defined?(mod::VectorStoreClassMethods)
        self::VectorStore.extend(mod::VectorStoreClassMethods)
      end

      if defined?(mod::ChunkerClassMethods)
        self::Chunker.extend(mod::ChunkerClassMethods)
      end

      if defined?(mod::PiiDetectorClassMethods)
        self::PiiDetector.extend(mod::PiiDetectorClassMethods)
      end

      mod.after_load(self, ...) if mod.respond_to?(:after_load)
    end

    plugin(:core)

    # @param source [String, Pathname]
    # @param logger [Logger]
    #
    # @return [Pipeline]

    def initialize(source, logger: nil)
      @source = source
      @logger = logger || VectorRecord.configuration.logger
      @loader = Loader.new(source, logger)
      @chunker = Chunker.new
      @embeddings = Embeddings.new
      @vector_store = VectorStore.new
      @pii_detector = PiiDetector.new
    end

    attr_reader :source,
                :logger,
                :loader,
                :chunker,
                :embeddings,
                :vector_store,
                :pii_detector

    # Executes the pipeline stages in order.
    #
    # @return [void]
    def run
      loader.load
      chunker.chunk
      embeddings.embeddings
      vector_store.add_documents
      pii_detector.anonymize
    end
  end
end
