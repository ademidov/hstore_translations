module HstoreTranslations
  module Macro

    def translates(*attributes)
      setup_hstore_translations
      self.translatable_attributes |= attributes.map(&:to_sym)

      attributes.each do |attribute|
        define_translations_reader(attribute)
        define_translations_writer(attribute)

        HstoreTranslations.available_locales.each do |locale|
          define_translations_reader(attribute, locale)
          define_translations_writer(attribute, locale)
        end
      end
    end

    private

    def setup_hstore_translations
      return if respond_to?(:translatable_attributes)

      class_attribute :translatable_attributes
      class_attribute :translations_methods

      self.translatable_attributes = []
      self.translations_methods = Module.new
      translations_methods.define_singleton_method :inspect do
        "HstoreTranslations::TranslationsMethods"
      end

      include translations_methods
      include AccessMethods
    end

    def define_translations_reader(attribute, locale = nil)
      name = locale ? "#{attribute}_#{locale}" : attribute
      translations_methods.module_eval do
        define_method(name) do
          @translations_readers ||= {}
          @translations_readers[name] ||= TranslationsLookup.new(self, attribute, locale)
          @translations_readers[name].value
        end
      end
    end

    def define_translations_writer(attribute, locale = nil)
      name = locale ? "#{attribute}_#{locale}=" : "#{attribute}="
      translations_methods.module_eval do
        define_method(name) do |value|
          write_locale = locale || HstoreTranslations.locale
          write_translated_attribute(attribute, write_locale, value)
        end
      end
    end
  end
end
