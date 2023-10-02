# frozen_string_literal: true

class FileValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    if content_types.exclude?(value.blob.content_type)
      value.purge
      record.errors.add(attribute, :invalid_content_type)
    elsif value.blob.byte_size > size_limit
      value.purge
      record.errors.add(attribute, :invalid_file_size)
    end
  end

private

  def content_types
    options.fetch(:content_type)
  end

  def size_limit
    options.fetch(:size_limit)
  end
end
