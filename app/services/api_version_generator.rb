# frozen_string_literal: true

class ApiVersionGenerator : ApiVersionService
  def call
    files.each do |file|
      new_file = new_file_path(file)
      create_new_directory(new_file)
      new_class_content = generate_new_class_content(file)
      File.write(new_file, new_class_content)
    end
  end
end
