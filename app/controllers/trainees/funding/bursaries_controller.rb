# frozen_string_literal: true

module Trainees
  module Funding
    class BursariesController < ApplicationController
      before_action :authorize_trainee

      def edit
        load_bursary_info!
        @bursary_form = ::Funding::BursaryForm.new(trainee)
      end

      def update
        @bursary_form = ::Funding::BursaryForm.new(trainee, params: bursary_params)

        save_strategy = trainee.draft? ? :save! : :stash

        if @bursary_form.public_send(save_strategy)
          redirect_to(trainee_funding_confirm_path)
        else
          load_bursary_info!
          render :edit
        end
      end

    private

      def trainee
        @trainee ||= Trainee.from_param(params[:trainee_id])
      end

      def bursary_params
        return { applying_for_bursary: nil } if params[:funding_bursary_form].blank?

        params.require(:funding_bursary_form).permit(:applying_for_bursary, :bursary_tier, :tiered_bursary_form)
      end

      def authorize_trainee
        authorize(trainee)
      end

      def load_bursary_info!
        @subject = trainee.course_subject_one
        @amount = funding_manager.bursary_amount
      end

      def funding_manager
        @funding_manager ||= FundingManager.new(trainee)
      end
    end
  end
end
