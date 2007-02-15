begin
  require 'test/spec'
rescue LoadError
  puts "==> The test/spec library (gem) is required to run the Gibberish tests."
  exit
end

$:.unshift File.dirname(__FILE__) + '/../lib'
require 'active_support'
require 'gibberish'

RAILS_ROOT = '.'
Gibberish.load_languages!

context "After loading languages, Gibberish" do
  teardown do
    Gibberish.current_language = nil
  end

  specify "should know what languages it has translations for" do
    Gibberish.languages.keys.should.include :es
  end

  specify "should know if it is using the default language" do
    Gibberish.should.be.default_language
  end

  specify "should be able to switch between existing languages" do
    Gibberish.current_language = :es
    string = "Welcome, friend!"
    string[:welcome_friend].should.not.equal string

    Gibberish.current_language = :fr
    string[:welcome_friend].should.not.equal string

    Gibberish.current_language = nil
    string[:welcome_friend].should.equal string
  end

  specify "should be able to switch languages using strings" do
    Gibberish.current_language = 'es'
    Gibberish.current_language.should.equal :es
  end

  specify "should be able to switch to the default language at any time" do
    Gibberish.current_language = :fr
    Gibberish.should.not.be.default_language

    Gibberish.current_language = nil
    Gibberish.should.be.default_language
  end
end

context "When no language is set" do
  setup do
    Gibberish.current_language = nil
  end

  specify "the default language should be used" do
    Gibberish.current_language.should.equal Gibberish.default_language
  end

  specify "a gibberish string should return itself" do
    string = "Welcome, friend!"
    Gibberish.translate(string, :welcome_friend).should.equal string

    string[:welcome_friend].should.equal string
  end
end

context "When a non-existent language is set" do
  setup do
    Gibberish.current_language = :klingon
  end

  specify "the default language should be used" do
    Gibberish.current_language.should.equal Gibberish.default_language
  end

  specify "gibberish strings should return themselves" do
    string = "something gibberishy"
    string[:welcome_friend].should.equal string
  end 
end

context "A gibberish string (in general)" do
  specify "should be a string" do
    "gibberish"[:just_a_string].should.be.an.instance_of String
    "non-gibberish".should.be.an.instance_of String
  end

  specify "should interpolate if passed arguments and replaces are present" do
    'Hi, {user} of {place}'[:hi_there, 'chris', 'france'].should.equal "Hi, chris of france"
    '{computer} omg?'[:puter, 'mac'].should.equal "mac omg?"
  end

  specify "should not affect existing string methods" do
    string = "chris"
    answer = 'ch'
    string[0..1].should.equal answer
    string[0, 2].should.equal answer
    string[0].should.equal 99
    string[/ch/].should.equal answer
    string['ch'].should.equal answer
    string['bc'].should.be.nil
    string[/dog/].should.be.nil
  end

  specify "should return nil if a reserved key is used" do
    "string"[:limit].should.be.nil
  end
end

context "When a non-default language is set" do
  setup do
    Gibberish.current_language = :es
  end

  specify "that language should be used" do
    Gibberish.current_language.should.equal :es
  end

  specify "the default language should not be used" do
    Gibberish.should.not.be.default_language
  end

  specify "a gibberish string should return itself if a corresponding key is not found" do
    string = "The internet!"
    string[:the_internet].should.equal string
  end

  specify "a gibberish string should return a translated version of itself if a corresponding key is found" do
    "Welcome, friend!"[:welcome_friend].should.equal "¡Recepción, amigo!"
    "I love Rails."[:love_rails].should.equal "Amo los carriles."
    'Welcome, {user}!'[:welcome_user, 'Marvin'].should.equal "¡Recepción, Marvin!"
  end
end
