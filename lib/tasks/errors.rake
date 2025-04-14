# frozen_string_literal: true

namespace :errors do
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
