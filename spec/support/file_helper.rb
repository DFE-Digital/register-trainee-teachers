# frozen_string_literal: true

module FileHelper
  def remove_file(filename)
    FileUtils.rm_f(filename)
  end

  def file_content(path)
    File.read(file(path))
  end

  def file(path)
    File.expand_path("../fixtures/files/#{path}", __dir__)
  end
end
