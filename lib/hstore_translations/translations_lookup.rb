module HstoreTranslations
  class TranslationsLookup
    attr_reader :model, :attribute

    def initialize(model, attribute, locale = nil)
      @model, @attribute, @locale = model, attribute, locale
      @locale = locale || HstoreTranslations.locale
    end

    def value
      fallbacks.each do |locale|
        value = try_locale(locale)
        return value if value.present?
      end
      nil
    end

    private

    def fallbacks
      HstoreTranslations.fallbacks(@locale)
    end

    def try_locale(locale)
      model.read_translated_attribute(attribute, locale)
    end
  end
end
