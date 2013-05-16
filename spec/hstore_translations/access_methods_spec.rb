# coding: utf-8
require 'spec_helper'

describe HstoreTranslations::AccessMethods do
  before { Post.send :include, HstoreTranslations::AccessMethods }
  let(:post) { Post.new }

  before do
    configure_i18n locale: :ru,
                   default_locale: :en,
                   available_locales: [:ru, :en, :es]
    Post.translates :title
  end

  describe '#write_translated_attribute' do
    it 'writes value to hstore' do
      post.write_translated_attribute(:title, :en, 'hello')
      post.save!
      post.reload.title_translations.should eq 'en' => 'hello'
    end
  end

  describe '#read_translated_attribute' do
    it 'reads value from hstore' do
      post.title_translations = { :en => 'hello' }
      post.save!
      post.reload.read_translated_attribute(:title, :en).should eq 'hello'
    end
  end

  describe '.with_translated' do
    let!(:post_1) { Post.create!(title_ru: 'hello') }
    let!(:post_2) { Post.create!(title_en: 'hello') }
    let!(:post_3) { Post.create!(title_es: 'hello') }
    let!(:post_4) { Post.create!(title_ru: 'привет') }

    subject { Post.with_translated(:title, 'hello') }

    context 'without locales given' do
      it 'includes records with translated attribute from current locale' do
        should include(post_1)
      end
      it 'includes records with translated attribute from default locale' do
        should include(post_2)
      end
      it 'does not include records with another locales' do
        should_not include(post_3)
      end
      it 'does not include records with another value' do
        should_not include(post_4)
      end
    end
    context 'with locale' do
      subject { Post.with_translated(:title, 'hello', :ru) }

      it 'includes matches from that locale' do
        should include(post_1)
      end
      it 'does not include matches from another locales' do
        should_not include(post_2, post_3, post_4)
      end
    end
  end

  describe '.order_by_translated' do
    let!(:post_1) { Post.create!(title_ru: 'a', title_en: 'c') }
    let!(:post_2) { Post.create!(title_ru: 'b', title_en: 'b') }
    let!(:post_3) { Post.create!(title_ru: 'c', title_en: 'a') }

    def ordered(*a)
      Post.order_by_translated(*a).select { |p| [post_1, post_2, post_3].include?(p) }
    end

    it 'accepts hash' do
      ordered(title: :desc).should eq [post_3, post_2, post_1]
    end
    it 'accepts symbol' do
      ordered(:title).should eq [post_1, post_2, post_3]
    end
    it 'accepts locale' do
      ordered(:title, :en).should eq [post_3, post_2, post_1]
    end
  end

  describe '.human_attribute_name' do
    before { configure_i18n locale: :en }
    before { Post.translates :title }

    def han(*a)
      Post.human_attribute_name(*a)
    end

    it 'uses default behaviour' do
      han(:title).should eq 'Title'
    end
    it 'uses default behaviour for locale-attributes' do
      han(:title_es).should eq 'Title (es)'
    end
    it 'appends language suffix when no translation for attribute' do
      han(:title_ru).should eq 'Russian title'
    end
  end

  describe '.translates?' do
    it 'is true when translates' do
      Post.translates?(:body).should be_false
      Post.translates :body
      Post.translates?(:body).should be_true
    end
  end

  describe '.locale_attibutes_for' do
    before { Post.translates :title, :body }

    it 'works with single attribute' do
      Post.locale_attributes_for(:title).should eq [:title_ru, :title_en, :title_es]
    end
    it 'works with multiple attributes' do
      attrs = Post.locale_attributes_for(:title, :body)
      attrs.should eq [:title_ru, :title_en, :title_es, :body_ru, :body_en, :body_es]
    end
  end
end

