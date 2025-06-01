require "csv"

class CsvReaderService
  def initialize(filepath)
    @filepath = filepath
  end

  def call
    CSV.read(
      @filepath,
      col_sep: ";",
      headers: true,
      encoding: "UTF-8"
    ).map(&:to_h)
  end
end
