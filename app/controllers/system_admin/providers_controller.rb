# frozen_string_literal: true

module SystemAdmin
  class ProvidersController < ApplicationController
    before_action :set_provider, only: %i[show edit update]

    def index
      @providers = authorize Provider.all.order(:name)
    end

    def new
      @provider = authorize Provider.new
    end

    def create
      @provider = authorize Provider.new(provider_params)

      if @provider.save
        redirect_to providers_path
      else
        render :new
      end
    end

    def show
      @users_view = UsersView.new(@provider)
    end

    def edit; end

    def update
      if @provider.update(provider_params)
        redirect_to providers_path
      else
        render :edit
      end
    end

  private

    def provider_params
      params.require(:provider).permit(:name, :dttp_id, :code, :apply_sync_enabled)
    end

    def set_provider
      @provider = authorize Provider.find(params[:id])
    end
  end
end
