# frozen_string_literal: true

# The early years teacher degree apprenticeship (EYTDA) is a separate route from
# initial teacher training (ITT), so its pages say "course" rather than "ITT",
# for example "Course start date" and "When did the trainee start their course?".
# Its wording is in
# config/locales/eytda.en.yml, under `eytda.` and the same key path as today's
# text. Other routes keep today's text.
module RouteTerminology
  EYTDA = TRAINING_ROUTE_ENUMS[:early_years_teacher_degree_apprenticeship]

  def self.eytda?(trainee)
    trainee.respond_to?(:training_route) && trainee.training_route.to_s == EYTDA
  end

  # The EYTDA wording for an EYTDA trainee when there is one, otherwise today's.
  def self.t(trainee, key, **)
    eytda_key = "eytda.#{key}"
    return I18n.t(eytda_key, **) if eytda?(trainee) && I18n.exists?(eytda_key)

    I18n.t(key, **)
  end

  # An ActiveModel error type: `eytda_blank` rather than `blank` for an EYTDA trainee.
  def self.error_type(trainee, type)
    eytda?(trainee) ? :"eytda_#{type}" : type
  end
end
