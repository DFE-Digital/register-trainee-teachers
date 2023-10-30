# frozen_string_literal: true

class UseCitextForSubjectNames < ActiveRecord::Migration[7.0]
  def up
    # allocation_subjects
    remove_index :allocation_subjects, :name, unique: true
    change_column :allocation_subjects, :name, :citext
    add_index :allocation_subjects, :name, unique: true

    # courses
    change_column :courses, :name, :citext, null: false

    # subject_specialisms
    remove_index :index_subject_specialisms_on_lower_name
    change_column :subject_specialisms, :name, :citext
    add_index :subject_specialisms, :name, unique: true

    # subjects
    change_column :subjects, :name, :citext, null: false

    # nationalities
    remove_index :index_nationalities_on_name
    change_column :nationalities, :name, :citext, null: false
    add_index :nationalities, :name, unique: true
  end

  def down
    # allocation_subjects
    remove_index :allocation_subjects, :name
    change_column :allocation_subjects, :name, :string
    add_index :allocation_subjects, :name, unique: true

    # courses
    change_column :courses, :name, :string, null: true

    # subject_specialisms
    remove_index :subject_specialisms, :name
    change_column :subject_specialisms, :name, :string
    add_index :subject_specialisms, :name, unique: true, name: 'index_subject_specialisms_on_lower_name'

    # subjects
    change_column :subjects, :name, :string, null: true

    # nationalities
    remove_index :nationalities, :name
    change_column :nationalities, :name, :string, null: true
    add_index :nationalities, :name, unique: true, name: 'index_nationalities_on_name'
  end
end
