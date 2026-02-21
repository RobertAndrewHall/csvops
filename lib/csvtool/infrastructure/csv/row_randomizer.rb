# frozen_string_literal: true

require "csv"
require "tempfile"

module Csvtool
  module Infrastructure
    module CSV
      class RowRandomizer
        DEFAULT_CHUNK_SIZE = 10_000

        def call(file_path:, col_sep:, headers:, seed: nil)
          each(file_path: file_path, col_sep: col_sep, headers: headers, seed: seed).to_a
        end

        def each(file_path:, col_sep:, headers:, seed: nil, chunk_size: DEFAULT_CHUNK_SIZE)
          chunk_paths = []
          return enum_for(:each, file_path: file_path, col_sep: col_sep, headers: headers, seed: seed, chunk_size: chunk_size) unless block_given?

          rng = seed.nil? ? Random.new : Random.new(seed)
          sequence = 0
          chunk_entries = []

          ::CSV.foreach(file_path, headers: headers, col_sep: col_sep) do |row|
            fields = headers ? row.fields : row
            chunk_entries << [rng.rand, sequence, fields]
            sequence += 1
            flush_chunk(chunk_entries, chunk_paths) if chunk_entries.length >= chunk_size
          end

          flush_chunk(chunk_entries, chunk_paths) unless chunk_entries.empty?
          merge_chunks(chunk_paths) { |fields| yield fields }
        ensure
          cleanup_chunks(chunk_paths)
        end

        private

        def flush_chunk(entries, chunk_paths)
          entries.sort_by! { |rand_key, seq, _fields| [rand_key, seq] }
          file = Tempfile.new("csvtool-row-randomizer-chunk")
          file.binmode
          entries.each { |entry| Marshal.dump(entry, file) }
          file.close
          chunk_paths << file.path
          entries.clear
        end

        def merge_chunks(chunk_paths)
          readers = chunk_paths.map { |path| File.open(path, "rb") }
          heads = readers.map { |reader| next_entry(reader) }

          loop do
            indexed = heads.each_with_index.select { |entry, _i| !entry.nil? }
            break if indexed.empty?

            min_entry, min_index = indexed.min_by { |entry, _i| [entry[0], entry[1]] }
            yield min_entry[2]
            heads[min_index] = next_entry(readers[min_index])
          end
        ensure
          readers&.each(&:close)
        end

        def next_entry(reader)
          Marshal.load(reader)
        rescue EOFError
          nil
        end

        def cleanup_chunks(chunk_paths)
          return if chunk_paths.nil?

          chunk_paths.each do |path|
            File.delete(path) if File.exist?(path)
          rescue Errno::EACCES, Errno::ENOENT
            nil
          end
        end
      end
    end
  end
end
