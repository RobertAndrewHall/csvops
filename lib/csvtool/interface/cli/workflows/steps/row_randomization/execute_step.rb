# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Steps
          module RowRandomization
            class ExecuteStep
              def call(context)
                session = context.fetch(:session)
                presenter = context.fetch(:presenter_factory).call(
                  headers: context.fetch(:headers),
                  col_sep: session.source.separator
                )

                presenter.print_console_start unless session.output_destination.file?
                result = context.fetch(:use_case).randomize(
                  session: session,
                  headers: context.fetch(:headers),
                  on_row: ->(fields) { presenter.print_row(fields) }
                )
                unless result.ok?
                  context.fetch(:handle_error).call(result)
                  return :halt
                end

                presenter.print_file_written(result.data[:output_path]) if session.output_destination.file?
                nil
              end
            end
          end
        end
      end
    end
  end
end
