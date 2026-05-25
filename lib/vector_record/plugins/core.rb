# frozen_string_literal: true

module VectorRecord
  module Plugins
    # Core plugin — provides default implementations for every pipeline stage.
    #
    # This module is automatically loaded by {VectorRecord::Pipeline} and serves
    # as the baseline behaviour that other plugins can override or extend.
    #
    # Sub-modules are kept in +plugins/core/+ and mixed into their respective
    # stage classes by {VectorRecord::Pipeline.plugin}.
    module Core
      VectorRecord::Pipeline.register_plugin(:core, self)
    end
  end
end

require_relative "core/loader_methods"
require_relative "core/embeddings_methods"
require_relative "core/vector_store_methods"
require_relative "core/chunker_methods"
require_relative "core/pii_detector_methods"
