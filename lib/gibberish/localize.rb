module Gibberish
  module Localize
    @@config = {}
    mattr_accessor :config

    @@languages = {}
    mattr_accessor :languages

    @@default_language = :en
    mattr_reader :default_language

    @@current_language = nil
    def current_language
      @@current_language || default_language
    end

    def current_language=(language)
      @@current_language = languages[language] ? language : nil
    end

    def default_language?
      current_language == default_language
    end

    def use_default_language
    end

    def translations
      @@languages[current_language] || {}
    end

    def translate(string, key, *args)
      target = translations[key] || string
      interpolate_string(target.dup, *args.dup)
    end

    def load_languages!
      language_files.each do |file| 
        key = File.basename(file, '.*').to_sym
        @@languages[key] = YAML.load_file(file).symbolize_keys
      end
    end

  private
    def interpolate_string(string, *args)
      string.gsub(/\{\w+\}/) { args.shift }
    end

    def language_files
      Dir[File.join(RAILS_ROOT, 'lang', '*.{yml,yaml}')]
    end
  end
end
