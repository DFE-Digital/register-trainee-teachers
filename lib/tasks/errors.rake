# frozen_string_literal: true

namespace :errors do
  task report: :environment do
    model_class = Api::V10Pre::TraineeAttributes
    model_class.validators.each do |validator|
      if validator.kind == :presence
        validator.attributes.each do |attribute|
          model = model_class.new
          model.errors.add(attribute, :blank)
          puts model.errors.full_messages
        end
      elsif validator.kind == :inclusion
        validator.attributes.each do |attribute|
          model = model_class.new
          model.errors.add(attribute, :inclusion)
          puts model.errors.full_messages
        end
      elsif validator.kind == :length
        validator.attributes.each do |attribute|
          model = model_class.new
          model.errors.add(attribute, :length)
          puts model.errors.full_messages
        end
      end
    end
  end

  desc "Dump a report of the error messages that we have in the system"
  task strings: :environment do
    puts "# ActiveRecord models"
    I18n.t('activerecord.errors.models').each do |model, model_errors|
      puts "## #{model}"
      model_errors[:attributes]&.each do |attribute, attribute_errors|
        if attribute_errors.is_a?(Hash) && attribute_errors.present?
          puts "### #{attribute}"
          attribute_errors.each do |error_type, error_message|
            puts "- #{error_message}"
          end
        end
      end
    end

    puts "# ActiveModel models"
    I18n.t('activemodel.errors.models').each do |model, model_errors|
      puts "## #{model}"
      model_errors[:attributes]&.each do |attribute, attribute_errors|
        if attribute_errors.is_a?(Hash) && attribute_errors.present?
          puts "### #{attribute}"
          attribute_errors.each do |error_type, error_message|
            puts "- #{error_message}"
          end
        end
      end
    end

    puts "# Generic validators"
    I18n.t('activemodel.errors.validators').each do |attribute, attribute_errors|
      if attribute_errors.is_a?(Hash) && attribute_errors.present?
        puts "### #{attribute}"
        attribute_errors.each do |error_type, error_message|
          puts "- #{error_message}"
        end
      end
    end
  end
end
