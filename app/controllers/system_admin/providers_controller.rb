# frozen_string_literal: true

module SystemAdmin
  class ProvidersController < ApplicationController
    before_action :set_provider, only: %i[show edit update destroy]

    def index
      @providers = authorize(
        Provider
          .select("providers.*, count(users.id) as user_count")
          .left_outer_joins(:users)
          .where("users.discarded_at": nil)
          .group("providers.id")
          .order(:name),
      )
    end

    def show
      @users_view = UsersView.new(@provider)
    end

    def new
      @provider = authorize(Provider.new)
    end

    def edit; end

    def create
      @provider = authorize(Provider.new(provider_params))

      if @provider.save
        redirect_to(providers_path)
      else
        render(:new)
      end
    end

    def update
      if @provider.update(provider_params)
        redirect_to(providers_path)
      else
        render(:edit)
      end
    end

    def destroy
      @provider.discard!

      flash[:success] = t("views.provider.delete")
      redirect_to(providers_path)
    end

  private

    def provider_params
      params.require(:provider).permit(:name, :dttp_id, :code, :ukprn, :accreditation_id, :apply_sync_enabled)
    end

    def set_provider
      @provider = authorize(Provider.find(params[:id]))
    end
  end
end
