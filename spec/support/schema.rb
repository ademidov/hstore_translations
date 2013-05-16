ActiveRecord::Schema.define(:version => 0) do
  enable_extension 'hstore'

  create_table :posts, :force => true do |t|
    t.hstore :title_translations
    t.hstore :body_translations
  end
end
