# coding: utf-8
require 'spec_helper'

describe HstoreTranslations::Macro, '.translates' do
  before do
    Post.new.should_not respond_to :title, :body
  end

  it 'is available' do
    Post.should respond_to :translates
  end
  it 'adds getters' do
    Post.translates :title
    Post.new.should respond_to :title
  end
  it 'adds setters' do
    Post.translates :title
    Post.new.should respond_to :title=
  end
  it 'adds locale-accessors' do
    methods = [:title_en, :title_ru, :title_en=, :title_ru=]
    Post.new.should_not respond_to *methods
    Post.translates :title
    Post.new.should respond_to *methods
  end
  it 'can be called multiple times' do
    Post.translates :title
    Post.new.should respond_to :title
    Post.new.should_not respond_to :body

    Post.translates :title, :body
    Post.new.should respond_to :title, :body
  end
  it 'can be called with multiple attributes' do
    Post.translates :title, :body
    Post.new.should respond_to :title, :body
  end
  it 'adds attributes to list' do
    Post.translates :title
    Post.locale_attributes.keys.should eq [:title]
    Post.translates :body
    Post.locale_attributes.keys.should eq [:title, :body]
  end
end

describe HstoreTranslations::Macro, 'generated accessors' do
  before { Post.translates :title }
  let(:post) { Post.new }

  describe '#title=' do
    before do
      configure_i18n locale: :en
      post.title = 'hello'
    end

    it 'assigns new value to current locale' do
      post.title.should eq 'hello'
      post.title_en.should eq 'hello'
    end
    it 'does not touch other locales' do
      post.title_ru.should be_nil
    end
  end

  describe '#title' do
    let(:post) { Post.new(title_en: 'hello', title_ru: 'привет', title_es: 'hola') }

    before do
      configure_i18n locale: :en,
                     default_locale: :ru
    end

    it 'is a title in current locale' do
      post.title.should eq 'hello'
    end

    it 'returns nil when there is no translations' do
      Post.new.title.should be_nil
    end

    context 'when title from current locale is empty' do
      before { post.title_en = nil }

      context 'and i18n fallbacks not enabled' do
        it 'tries to load defaut locale' do
          post.title.should eq 'привет'
        end
      end
      context 'and i18n fallbacks enabled' do
        before do
          configure_i18n fallbacks: { en: [:es, :ru] }
        end
        after { I18n.fallbacks = false }

        it 'looks for translation in fallback chain' do
          post.title.should eq 'hola'
          post.title_es = nil
          post.title.should eq 'привет'
        end
      end
    end
  end

  describe '#title_en' do
    before do
      configure_i18n locale: :en,
                     default_locale: :ru,
                     available_locales: [:en, :ru]
      Post.translates :title
    end

    it 'does not attempt to get value with fallbacks' do
      post.title_ru = 'hello'
      post.title_en.should be_nil
    end
  end
end
