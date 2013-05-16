require 'active_record'
require 'hstore_translations'
require 'i18n/backend/fallbacks'

db_config = YAML.load_file(File.expand_path('../support/database.yml', __FILE__))['test']
ActiveRecord::Base.establish_connection(db_config)
I18n.load_path << 'spec/support/en.yml'

require 'support/schema'
require 'support/models'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.order = 'random'

  config.before :each do
    Object.send(:remove_const, :Post)
    load 'support/models.rb'
  end
  config.after :each do
    configure_i18n available_locales: [:ru, :en, :es],
                   default_locale: :ru,
                   locale: :ru,
                   fallbacks: false
  end
end

def configure_i18n(options)
  options.each do |key, value|
    I18n.send("#{key}=", value)
  end
end
