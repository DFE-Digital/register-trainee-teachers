# frozen_string_literal: true

class SyncRotpProvidersAccreditation < ActiveRecord::Migration[8.1]
  # https://trello.com/c/PfJaOqoD/9622-change-some-accredited-providers-in-register-to-align-with-rotp
  #
  def up
    [
      %w[S13 scitt],
      %w[W53 scitt],
      %w[S25 scitt],
      %w[T29 scitt],
      %w[E75 scitt],
      %w[1WR scitt],
      %w[1WU scitt],
      %w[24U scitt],
      %w[P57 scitt],
      %w[2A6 scitt],
      %w[25D scitt],
      %w[B31 scitt],
      %w[C36 scitt],
      %w[L19 scitt],
      %w[24P scitt],
      %w[H72 hei],
      %w[B35 hei],
      %w[24M scitt],
      %w[2AW scitt],
      %w[N46 scitt],
      %w[1MN scitt],
      %w[24R scitt],
      %w[D40 scitt],
      %w[186 scitt],
      %w[4L6 scitt],
      %w[255 scitt],
      %w[R16 scitt],
      %w[R55 scitt],
      %w[1WE scitt],
      %w[1WJ scitt],
      %w[2H8 scitt],
      %w[H38 scitt],
      %w[L75 hei],
      %w[P60 hei],
      %w[D41 scitt],
      %w[1YS scitt],
    ].each do |code, record_type|
      provider = Provider.find_by!(code:)

      CopyProvidersToTrainingPartnersService.call(provider_ids: [provider.id], record_type: record_type)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
