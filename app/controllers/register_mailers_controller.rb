# frozen_string_literal: true

module RegisterMailersController
  def preview
    prepend_view_path("spec/mailers/previews")
    super
  end
end
