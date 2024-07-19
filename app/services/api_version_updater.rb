# frozen_string_literal: true

class ApiVersionUpdater : ApiVersionService
  def call
    puts "Copying #{old_version} to #{new_version}..."
    files.each do |file|
      new_file = new_file_path(file)
      create_new_directory(new_file)
      new_class_content = generate_new_class_content(file)
      puts "writing #{new_file}"
      File.write(new_file, new_class_content)
      puts "deleting #{file}"
      File.delete(file)
    end
  end
end
