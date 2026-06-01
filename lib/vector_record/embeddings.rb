# frozen_string_literal: true

module VectorRecord
  module Embeddings
    PROVIDERS = {}
    def self.register_provider(provider_name, mod)
      PROVIDERS[provider_name] = mod
    end

    def self.load(provider_name, target)
      require "vector_record/embeddings/#{provider_name}_embeddings"
      mod = PROVIDERS.fetch(provider_name)

      target.include(mod::ProviderMethods) if mod.const_defined?(:ProviderMethods)
      target.extend(mod::ProviderClassMethods) if mod.const_defined?(:ProviderClassMethods)
    end
  end
end
