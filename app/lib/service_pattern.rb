# frozen_string_literal: true

module ServicePattern
  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      private_class_method(:new)
    end
  end

  def call
    raise(NotImplementedError("#call must be implemented"))
  end

  module ClassMethods
    def call(*args, **keyword_args, &block)
      return new.call if args.empty? && keyword_args.empty? && block.nil?

      new(*args, **keyword_args, &block).call
    end
  end
end
