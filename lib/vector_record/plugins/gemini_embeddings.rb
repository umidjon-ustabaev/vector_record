# frozen_string_literal: true

require "faraday"

module VectorRecord
  module Plugins
    module GeminiEmbeddings
      VectorRecord::Pipeline.register_plugin(:gemini_embeddings, self)
      module EmbeddingsMethods
        BASE_URL = "https://generativelanguage.googleapis.com"
        private_constant :BASE_URL

        # @return [String] Gemini API key
        attr_reader :api_key

        # @return [String] embedding model name
        attr_reader :model

        # @return [String] base URL for the Gemini API
        attr_reader :base_url

        # @param config [VectorRecord::Configuration::Embeddings]
        def initialize(config: VectorRecord.configuration.embeddings)
          api_key = config.api_key || ENV["GEMINI_API_KEY"]
          raise ArgumentError, "Gemini API key is required, set through env GEMINI_API_KEY or config" if api_key.nil?
          raise ArgumentError, "Gemini model name is required" if config.model.nil?

          @api_key = api_key
          @model = config.model
          @base_url = config.base_url || ENV["GEMINI_BASE_URL"] || BASE_URL
        end

        # Returns a memoized Faraday client configured for the Gemini API.
        #
        # @return [Faraday::Connection]
        def client
          @client ||= Faraday.new(url: base_url) do |con|
            con.request :json
            con.response :json
            con.headers["Content-Type"] = "application/json"
            con.headers["x-goog-api-key"] = api_key
          end
        end

        # Generates embeddings for each document and assigns them in place.
        # Uses the batchEmbedContents endpoint to embed all documents in a single request.
        #
        # @param documents [Array<Pipeline::Document>] documents whose +page_content+ will be embedded
        # @return [Array<Pipeline::Document>] the same documents with +embeddings+ populated
        def embed_documents(documents)
          response = client.post(batch_endpoint) do |req|
            req.body = {
              requests: documents.map do |doc|
                { model: "models/#{model}", content: { parts: [ { text: doc.page_content } ] } }
              end
            }
          end

          raise StandardError, "Gemini embedding request failed (HTTP #{response.status})" unless response.success?

          response.body.fetch("embeddings").each_with_index do |embedding, i|
            documents[i].embeddings = embedding["values"]
          end

          documents
        end

        # Generates an embedding vector for a single string.
        #
        # @param text [String] the text to embed
        # @return [Array<Float>] the embedding vector
        def embed_text(text)
          response = client.post(embed_endpoint) do |req|
            req.body = { model: "models/#{model}", content: { parts: [ { text: text } ] } }
          end

          raise StandardError, "Gemini embedding request failed (HTTP #{response.status})" unless response.success?

          response.body.dig("embedding", "values")
        end

        private

        def batch_endpoint
          @batch_endpoint ||= "/v1beta/models/#{model}:batchEmbedContents"
        end

        def embed_endpoint
          @embed_endpoint ||= "/v1beta/models/#{model}:embedContent"
        end
      end
    end
  end
end
