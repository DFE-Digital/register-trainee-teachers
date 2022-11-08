# frozen_string_literal: true

module FileHelper
  def remove_file(filename)
    FileUtils.rm_f(filename)
  end
end
