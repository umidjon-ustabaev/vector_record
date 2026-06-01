# frozen_string_literal: true

module VectorRecord
  module Plugins
    module Core
      # Instance methods mixed into VectorRecord::Pipeline::Loader.
      #
      # Provides file-based document loading that yields {Document} objects to
      # the pipeline. Each loader is initialized with a source path and a logger,
      # then drives the pipeline by calling {#load}.
      #
      # @example
      #   class MyLoader
      #     include VectorRecord::Plugins::Core::LoaderMethods
      #   end
      #
      #   MyLoader.new("path/to/file.txt", logger).load { |doc| process(doc) }
      module LoaderMethods
        attr_reader :source, :logger

        # @param source [String] path to the file to load
        # @param logger [Logger] logger instance for progress output
        def initialize(source, logger)
          @source = source
          @logger = logger
        end

        # Reads the source file and yields a single {Document} to the caller.
        #
        # @yieldparam document [Document] the loaded document
        # @return [void]
        def load
          logger.info("Loading data...")
          File.open(source, "r") do |file|
            yield Pipeline::Document.new(
              id: nil,
              source: source,
              page_content: file.read,
              metadata: { source: source }
            )
          end
        end
      end
    end
  end
end
