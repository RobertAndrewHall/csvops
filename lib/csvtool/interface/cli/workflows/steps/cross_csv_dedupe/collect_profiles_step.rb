# frozen_string_literal: true

require "csvtool/domain/cross_csv_dedupe_session/csv_profile"

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Steps
          module CrossCsvDedupe
            class CollectProfilesStep
              def initialize(file_path_prompt:, separator_prompt:, headers_present_prompt:, errors:)
                @file_path_prompt = file_path_prompt
                @separator_prompt = separator_prompt
                @headers_present_prompt = headers_present_prompt
                @errors = errors
              end

              def call(context)
                source_path = @file_path_prompt.call
                return @errors.file_not_found(source_path) || :halt unless File.file?(source_path)

                source_col_sep = @separator_prompt.call(label: "Source CSV separator:")
                return :halt if source_col_sep.nil?
                source_headers_present = @headers_present_prompt.call(label: "Source headers present? [Y/n]: ")

                reference_path = @file_path_prompt.call(label: "Reference CSV file path: ")
                return @errors.file_not_found(reference_path) || :halt unless File.file?(reference_path)

                reference_col_sep = @separator_prompt.call(label: "Reference CSV separator:")
                return :halt if reference_col_sep.nil?
                reference_headers_present = @headers_present_prompt.call(label: "Reference headers present? [Y/n]: ")

                context[:source] = Domain::CrossCsvDedupeSession::CsvProfile.new(
                  path: source_path,
                  separator: source_col_sep,
                  headers_present: source_headers_present
                )
                context[:reference] = Domain::CrossCsvDedupeSession::CsvProfile.new(
                  path: reference_path,
                  separator: reference_col_sep,
                  headers_present: reference_headers_present
                )
                nil
              end
            end
          end
        end
      end
    end
  end
end
