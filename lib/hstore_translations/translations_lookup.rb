module HstoreTranslations
  class TranslationsLookup
    attr_reader :model, :attribute

    def initialize(model, attribute, locale = nil)
      @model, @attribute, @locale = model, attribute, locale
      @locale = locale
    end

    def value
      if @locale
        try_locale(@locale)
      else
        fallbacks.inject(nil) do |_, locale|
          value = try_locale(locale)
          return value if value.present?
        end
      end
    end

    private

    def fallbacks
      HstoreTranslations.fallbacks(@locale || HstoreTranslations.locale)
    end

    def try_locale(locale)
      model.read_translated_attribute(attribute, locale)
    end
  end
end
