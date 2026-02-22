# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Steps
          module CrossCsvDedupe
            class ExecuteStep
              def call(context)
                session = context.fetch(:session)
                presenter = context.fetch(:presenter_factory).call(col_sep: session.source.separator)

                result = context.fetch(:use_case).call(
                  session: session,
                  on_header: ->(headers) { presenter.print_header(headers) },
                  on_row: ->(fields) { presenter.print_row(fields) }
                )
                unless result.ok?
                  context.fetch(:handle_error).call(result)
                  return :halt
                end

                presenter.print_file_written(result.data[:output_path]) if session.output_destination.file?
                presenter.print_summary(result.data[:stats])
                nil
              end
            end
          end
        end
      end
    end
  end
end
