module Trainees
  module Withdrawal
    class Base < Trainees::BaseController
      helper_method :form, :trainee

      def edit
        @form = form_class.new(trainee)
      end

      def update
        @form = form_class.new(trainee, params: form_params)
        if form.stash_or_save!
          redirect_to next_page
        else
          render :edit
        end
      end

      private

      attr_reader :form

      def form_param_key
        @form_param_key ||= form_class.new(trainee).model_name.param_key
      end

      def form_params
        @form_params ||= [attribute_names].flatten.index_with do |name|
          params.dig(form_param_key, name)
        end
      end

      def form_class
        raise NotImplementedError, 'Child class must define a form_class method'
      end

      def attribute_names
        raise NotImplementedError, 'Child class must define an attribute_names method'
      end
    end
  end
end