# frozen_string_literal: true

class BackfillMissingDegreeUuids < ActiveRecord::Migration[6.1]
  def up
    %i[institution subject uk_degree grade].each do |attribute|
      uuid_attribute = "#{attribute}_uuid"
      Degree.uk.where.not(attribute => nil).where(uuid_attribute => nil).each do |degree|
        find_method_name = attribute == :uk_degree ? :find_type : "find_#{attribute}"
        attribute_uuid = Degrees::DfEReference.public_send(find_method_name, name: degree[attribute])&.id
        degree.update_column(uuid_attribute, attribute_uuid) if attribute_uuid
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
