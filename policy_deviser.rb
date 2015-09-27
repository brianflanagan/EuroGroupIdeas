require 'engtagger'

class PolicyDeviser
  def self.generate_policy
    country = choose_country
    noun = nil

    while !noun do
      noun = find_noun_for_country(country)
    end

    case [:urge, :behove].sample
    when :urge
      "We #{ urge_predicate } #{ country[:name] } to privatise its #{ noun }."
    when :behove
      "It #{ behove_predicate } #{ country[:name] } to privatise its #{ noun }."
    end
  end

private

  def self.urge_predicate
    adverb = ['strongly','emphatically','enthusiastically','passionately','exuberantly','fervently',nil].sample
    verb = ['urge','pressure','encourage','admonish','beseech','exhort'].sample
    [adverb, verb].compact.join(' ')
  end

  def self.behove_predicate
    ['behoves', 'is incumbent on', 'would be prudent for', 'is advisable for', 'is sensible for'].sample
  end

  def self.privatise_synonym
    ['privatise','subcontract'].sample
  end

  def self.find_noun_for_country(country)
    $twitter.search("lang:en -rt #{ country[:demonym] }", result_type: "recent", count: 100).shuffle.each do |tweet|
      word = get_noun_after_demonym(tweet.text.downcase, country[:demonym])

      next unless word && word.size > 2

      puts " >> " + tweet.text
      return word
    end

    nil
  end

  def self.get_noun_after_demonym(tweet_text, country_demonym)
    tgr = EngTagger.new
    tagged = tgr.add_tags(after_demonym)
    nouns = tgr.get_noun_phrases(tagged).keys.sort_by { |i| i.length }.reverse
    nouns.each do |noun|
      return(noun) if tweet_text.include?("#{ country_demonym } #{ noun }")
    end
  end

  def self.choose_country
    [
      {name: 'Portugal', demonym: 'portuguese'},
      {name: 'Ireland', demonym: 'irish'},
      {name: 'Italy', demonym: 'italian'},
      {name: 'Greece', demonym: 'greek'},
      {name: 'Spain', demonym: 'spanish'},
      {name: 'Portugal', demonym: "portugal's"},
      {name: 'Ireland', demonym: "ireland's"},
      {name: 'Italy', demonym: "italy's"},
      {name: 'Greece', demonym: "greece's"},
      {name: 'Spain', demonym: "spain's"}
    ].sample
  end
end