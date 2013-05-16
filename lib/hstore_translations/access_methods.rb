module HstoreTranslations
  module AccessMethods
    extend ActiveSupport::Concern

    def read_translated_attribute(name, locale)
      read_store_attribute("#{name}_translations", locale)
    end

    def write_translated_attribute(name, locale, value)
      write_store_attribute("#{name}_translations", locale, value)
    end

    module ClassMethods
      def with_translated(name, value, locales = HstoreTranslations.fallbacks)
        hstore_query_parts = Array(locales).map do |locale|
          "#{table_name}.#{name}_translations @> '#{locale}=>#{value}'"
        end
        where(hstore_query_parts.join(' OR '))
      end

      def order_by_translated(arg, locale = HstoreTranslations.locale)
        name, mode = if arg.is_a?(Hash)
          [arg.keys.first, arg.values.first]
        else
          [arg, :asc]
        end
        order("#{table_name}.#{name}_translations->'#{locale}' #{mode}")
      end

      def human_attribute_name(name, options = {})
        default = super(name, options.merge(default: ''))
        attribute, locale = name.to_s.match(/\A(\w+)_([a-z]{2})\z/).try(:captures)

        if default.blank? && attribute && translates?(attribute)
          "#{super(attribute, options)} (#{locale})"
        else
          super
        end
      end

      def translates?(name)
        locale_attributes.has_key?(name.to_sym)
      end
    end
  end
end
