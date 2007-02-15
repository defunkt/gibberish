module Gibberish
  module Localize
    @@default_language = :en
    mattr_reader :default_language

    @@reserved_keys = [ :limit ]
    mattr_reader :reserved_keys

    def add_reserved_key(*key)
      (@@reserved_keys += key.flatten).uniq!
    end
    alias :add_reserved_keys :add_reserved_key

    @@languages = {}
    def languages
      @@languages.keys
    end

    @@current_language = nil
    def current_language
      @@current_language || default_language
    end

    def current_language=(language)
      load_languages! if defined? RAILS_ENV && RAILS_ENV == 'development'

      language = language.to_sym if language.respond_to? :to_sym
      @@current_language = @@languages[language] ? language : nil
    end

    def use_language(language)
      start_language = current_language
      self.current_language = language
      yield
      self.current_language = start_language
    end

    def default_language?
      current_language == default_language
    end

    def translations
      @@languages[current_language] || {}
    end

    def translate(string, key, *args)
      return if reserved_keys.include? key
      target = translations[key] || string
      interpolate_string(target.dup, *args.dup)
    end

    def load_languages!
      language_files.each do |file| 
        key = File.basename(file, '.*').to_sym
        @@languages[key] = YAML.load_file(file).symbolize_keys
      end
      languages
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
