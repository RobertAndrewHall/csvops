# frozen_string_literal: true

module Csvtool
  module Application
    module UseCases
      class RunCsvParity
        Result = Struct.new(:ok, :error, :data, keyword_init: true) do
          def ok?
            ok
          end
        end

        def call(left_path:, right_path:)
          Result.new(ok: true, error: nil, data: { left_path: left_path, right_path: right_path })
        end
      end
    end
  end
end
