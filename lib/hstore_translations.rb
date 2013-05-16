require 'hstore_translations/version'
require 'hstore_translations/macro'
require 'hstore_translations/access_methods'
require 'hstore_translations/translations_lookup'

module HstoreTranslations
  class << self
    delegate :locale, :default_locale, :available_locales, to: :I18n

    def fallbacks(for_locale = locale)
      I18n.respond_to?(:fallbacks) ? I18n.fallbacks[for_locale] : default_fallbacks(for_locale)
    end

    private

    def default_fallbacks(for_locale)
      [for_locale.to_sym, default_locale].uniq
    end
  end
end

ActiveRecord::Base.send :extend, HstoreTranslations::Macro
