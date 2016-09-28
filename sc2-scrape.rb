require 'open-uri'
require 'nokogiri'
require 'pp'
require 'active_support'
require 'active_support/core_ext'
require 'json'

uri = 'http://us.battle.net/sc2/en/game/unit/'

content = open(uri).read

units = []

catalog = {}

# Battle.net lacks number-of-hits-per-attack.
# E.g. a zealot strikes twice per attack;
# each strike is worth 8 damage;
# 2-strikes at 8-damage each = 16 damage.
# This data is appended to the scraped-data.

# to-do:
# There are 3 vaules for energy:
# 1. Starting
# 2. Maximum
# 3. Regeneration

# Extraction functions.
#
# Write your function from the perspective of having exactly 1
# Nokogiri::XML::Element, representing a <td>, and containing
# all the content you want.
#
ef = [
  # f[0]
  # A function is always required, even if it "does nothing".
  lambda { |_| :pass },

  # f[1]
  # Simple texts.
  lambda { |td| td.text.strip },

  # f[2]
  # Simple integers.
  lambda { |td| td.text.strip.to_i },

  # f[3]
  # Health and shields can regenerate; the regeneration value is
  # inside the <td> for the respective life/shield value. Break
  # it out into its own attribute.
  lambda { |td| td.text.strip.split(/\s+/).last.to_f },

  # f[4]
  # Extract movement's integer from the tool-tip.
  lambda { |td| td.search('span').text.strip },

  # f[5]
  # Extract mineral-cost.
  lambda { |td| td.search('span')[0].text.to_i },

  # f[6]
  # Extract vespene-cost.
  lambda { |td| td.search('span')[1].text.to_i },

  # f[7]
  # Extract 'attributes', e.g. biological, mechanical, psionic, etc.
  lambda { |td| td.text.split('-').collect(&:strip) }
]


per_unit_data = {
  # basic information
  'race'         => ef[1],
  'life'         => ef[2],
  'shield'       => ef[2],
  'regeneration' => ef[3],
  'armor'        => ef[2],
  'energy'       => ef[0],
  'movement'     => ef[4],
  'cargo size'   => ef[2],
  'attributes'   => ef[7],

  # production stats
  'producer'     => ef[1],
  'hotkey'       => ef[0],
  'requires'     => ef[1],
  'cost'         => ef[0],
  'mineral-cost' => ef[5],
  'vespene-cost' => ef[6],
  'supply'       => ef[2],
  'build time'   => ef[2],

  # combat stats, to-do
  'upgrades' => :pass, # to-do
  'weapon'   => :pass, # to-do
  'ability'  => :pass  # to-do
}

# e.g. Core.goTo('probe')
content.scan(%r{Core\.goTo\('(.+)'\)}).each do |unit|
  units << unit[0]
end

units.uniq!

units.each do |unit|
  puts "Copying #{unit}..."
  content = open(uri + unit).read
  doc = Nokogiri::HTML.parse(content)

  bi = {} # basic information

  # Following are 3 stanzas, each operating on successive columns-of-data found
  # on the Battle.net pages. e.g. http://us.battle.net/sc2/en/game/unit/scv

  doc.search('.statistics-content')[0].search('.basic-stats > table > tr').each do |tr|
    l = tr.search('td')[0].text.parameterize(' ')

    raise "label [#{l}] lacking implementation" unless per_unit_data.has_key?(l)

    if ['life', 'shield'].include?(l)
      if tr.search('td')[1].text.include?('Regeneration')
        bi[l + '-regeneration'] = per_unit_data['regeneration'].call(tr.search('td')[1])
      end
    end

    bi[l] = per_unit_data[l].call(tr.search('td')[1])
  end

  doc.search('.statistics-content')[0].search('.production-stats > table > tr').each do |tr|
    l = tr.search('td')[0].text.parameterize(' ')

    raise "label [#{l}] lacking implementation" unless per_unit_data.has_key?(l)

    if l == 'cost'
      bi['mineral-cost'] = per_unit_data['mineral-cost'].call(tr.search('td')[1])
      bi['vespene-cost'] = per_unit_data['vespene-cost'].call(tr.search('td')[1])
    end

    bi[l] = per_unit_data[l].call(tr.search('td')[1])
  end

  doc.search('.statistics-content')[0].search('.combat-stats > table > tr').each do |tr|
    # to-do
  end

  catalog[unit] = bi

  sleep(2)
end

open('sc2-data.json', 'w') { |f| f << catalog.to_json }
