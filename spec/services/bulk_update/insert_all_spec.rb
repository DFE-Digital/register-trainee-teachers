require 'rails_helper'

RSpec.describe BulkUpdate::InsertAll, type: :service do
  let(:trainee) { create(:trainee) }
  let(:original) { { trainee.id => { first_names: 'John', updated_at: 'some_time' } } }
  let(:modified) { { trainee.id => { first_names: 'Johnny', updated_at: 'some_other_time' } } }
  let(:expected_changes) { { first_names: ['John', 'Johnny'], updated_at: ['some_time', 'some_other_time'] } }

  before do
    allow(Trainee).to receive(:find).and_return([instance_double('Trainee')])
    allow(Trainee).to receive(:upsert_all)
    allow(DfE::Analytics::SendEvents).to receive(:do)
    allow(Auditing::BackfillJob).to receive(:perform_later)
  end

  describe 'enqueue_audit_jobs' do
    it 'passes the correct attributes to the audit jobs' do
      BulkUpdate::InsertAll.call(
        original: original,
        modified: modified,
        model: Trainee,
        unique_by: :slug
      )

      expect(Auditing::BackfillJob).to have_received(:perform_later).with(
        hash_including(
          model: Trainee,
          id: an_instance_of(Integer),
          changes: expected_changes
        )
      ).once
    end
  end
end
