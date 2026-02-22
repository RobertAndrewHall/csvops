# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Prompts
        class SplitManifestPrompt
          def initialize(stdin:, stdout:, yes_no_prompt:)
            @stdin = stdin
            @stdout = stdout
            @yes_no_prompt = yes_no_prompt
          end

          def call(default_path:)
            write_manifest = @yes_no_prompt.call(
              label: "Write manifest file? [y/N]: ",
              default: false
            )
            return { write_manifest: false, manifest_path: nil } unless write_manifest

            @stdout.print "Manifest file path [#{default_path}]: "
            path = @stdin.gets&.strip.to_s
            path = default_path if path.empty?
            { write_manifest: true, manifest_path: path }
          end
        end
      end
    end
  end
end
