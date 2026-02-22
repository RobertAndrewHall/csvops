# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Prompts
        class SplitOutputPrompt
          def initialize(stdin:, stdout:, yes_no_prompt:)
            @stdin = stdin
            @stdout = stdout
            @yes_no_prompt = yes_no_prompt
          end

          def call(default_directory:, default_prefix:)
            @stdout.print "Output directory [#{default_directory}]: "
            output_directory = @stdin.gets&.strip.to_s
            output_directory = default_directory if output_directory.empty?

            @stdout.print "Output file prefix [#{default_prefix}]: "
            file_prefix = @stdin.gets&.strip.to_s
            file_prefix = default_prefix if file_prefix.empty?

            overwrite_existing = @yes_no_prompt.call(
              label: "Overwrite existing chunk files? [y/N]: ",
              default: false
            )

            {
              output_directory: output_directory,
              file_prefix: file_prefix,
              overwrite_existing: overwrite_existing
            }
          end
        end
      end
    end
  end
end
