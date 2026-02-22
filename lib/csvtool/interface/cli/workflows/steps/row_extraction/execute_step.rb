# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Steps
          module RowExtraction
            class ExecuteStep
              def initialize(stdout:, errors:, presenter_class: Presenters::RowExtractionPresenter)
                @stdout = stdout
                @errors = errors
                @presenter_class = presenter_class
              end

              def call(context)
                session = context.fetch(:session)
                presenter = @presenter_class.new(
                  stdout: @stdout,
                  headers: context.fetch(:headers),
                  col_sep: ","
                )
                result = context.fetch(:use_case).extract(
                  session: session,
                  headers: context.fetch(:headers),
                  on_row: ->(fields) { presenter.print_row(fields) }
                )
                unless result.ok?
                  context.fetch(:handle_error).call(result)
                  return :halt
                end

                presenter.print_file_written(result.data[:output_path]) if result.data[:wrote_rows]
                @errors.row_range_out_of_bounds(result.data[:row_count]) unless result.data[:matched]
                nil
              end
            end
          end
        end
      end
    end
  end
end
