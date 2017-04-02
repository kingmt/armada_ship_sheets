require 'nokogiri'
require 'httparty'
require 'open-uri'
require_relative 'sheet_generator'

# url = 'http://armadawarlords.hivelabs.solutions/view_list.php?token=79367'
# /(\d+)$/ =~ url
# armada_fleet_token = $1
# doc = Nokogiri::HTML(open(url))
#
# armada_fleet_name = doc.css('.h1.hidden-print').text.strip.gsub(/\W/,'_')
# ships = doc.css '.ship-block'
#
# ship = ships.first
# ship.css( '.ship-title-head').text.strip
#  => "Victory II-Class Star Destroyer"
#
# ship.css( '.ship-base-points').text.strip
#  => "85"
#
# # not parsing correctly for some reason - should be 36
# ship.css( '.ship-upgrade-points-total').text.strip
#  => "0"
#
# ship.css( '.fb_ship_image').attribute( 'src').value
#  => "/assets/cards/ships/empire/victory-II.png"
#
# # flagship
# ship.css('.css-checkbox').children[1].attributes['checked'].value
#  => "checked"
# ship.css('.css-checkbox')
#  => []
#
#
#
# ship.css('.ship-body')
# upgrades = ship.css('.upgrade-block')
# upgrades.count
#  => 6
#
# upgrade_1 = upgrades.first
# upgrade_1.attributes["data-upgrade"].value
#  => "Title"
#
# upgrade_1.css('.fb_upgrade_image').attribute('src').value
#  => "/assets/cards/upgrades/corrupter.png"
# upgrade_1.css('.fb_upgrade_image').attribute('data-upgrade-cost').value
#  => "5"
#
# upgrades.collect {|u| u.css('.fb_upgrade_image').attribute('src').value}
#  => ["/assets/cards/upgrades/corrupter.png", "/assets/cards/upgrades/commandant-aresko.png", "/assets/cards/upgrades/veterangunners.png", "/assets/cards/upgrades/point-defense-reroute.png", "/assets/cards/upgrades/slaved-turrets.png", "/assets/cards/upgrades/overload-Pulse.png"]
# upgrades.collect {|u| u.css('.fb_upgrade_image').attribute('data-upgrade-cost').value.to_i}.reduce(:+)
#  => 36
# upgrades.collect{|u| u.attributes["data-upgrade"].value }
#  => ["Title", "Officer", "WT1", "OR1", "T1", "IC1"]
#
# # squadrons
# squadrons = doc.css('.squadron-view-block')
# quadrons.count
#  => 2
#
# sq = squadrons.first
# sq.css('.squadron-title-head').text
#  => "\"Mauler\" Mithel"
#
# sq.css('.squadron-squadrons').text
#  => "1"
# sq.css('.squadron-total-points').text
#  => "15"
# sq.css('.fb_squadron_image').attribute('src').value
#  => "/assets/cards/squadrons/empire/mauler-mithel.png"
#
# sq2 = squadrons[1]
# sq2.css('.squadron-title-head').text
#  => "TIE Fighter Squadron"
# sq2.css('.squadron-squadrons').text
#  => "2"
# sq2.css('.squadron-total-points').text
#  => "16"
# sq2.css('.fb_squadron_image').attribute('src').value
#  => "/assets/cards/squadrons/empire/tie.png"

def get_all_ships doc
  all_ships = doc.css '.ship-block'
  all_ships.collect do |ship|
    result = {}
    upgrades = ship.css('.upgrade-block')
    result['ship_type'] = ship.css( '.ship-title-head').text.strip
    result['base_points'] = ship.css( '.ship-base-points').text.strip
    result['upgrade_points'] = upgrades.collect {|u| u.css('.fb_upgrade_image').attribute('data-upgrade-cost').value.to_i}.reduce(:+)
    result['flagship'] = !ship.css('.css-checkbox').empty?
    result['ship_image'] = ship.css( '.fb_ship_image').attribute( 'src').value.prepend('..')
    result['upgrades'] = upgrades.collect {|u| u.css('.fb_upgrade_image').attribute('src').value.prepend('..')}
    result
  end
end

def get_all_squadrons doc
  all_squadrons = doc.css('.squadron-view-block')
  all_squadrons.collect do |sq|
    result = {}
    result['name'] = sq.css('.squadron-title-head').text
    result['count'] = sq.css('.squadron-squadrons').text
    result['total_cost'] = sq.css('.squadron-total-points').text
    result['image'] = sq.css('.fb_squadron_image').attribute('src').value.prepend('..')
    result
  end
end


#def parse_warlord_fleet url
  url = ARGV[0]
  # url = 'http://armadawarlords.hivelabs.solutions/view_list.php?token=80931'
  /token=(\d+)/ =~ url
  token = $1
  doc = Nokogiri::HTML(open(url))

  fleet_data = {"name" => doc.css('.h1.hidden-print').text.strip.gsub(/\W+/,'_'),
                "token" => token,
                "ships" => get_all_ships(doc),
                "squadrons" => get_all_squadrons(doc)
  }

  # generate pdf
  file_name = "../#{fleet_data["name"]}_#{fleet_data["token"]}.pdf"
  yaml_file_name = "../#{fleet_data["name"]}_#{fleet_data["token"]}.yml"
  File.open(yaml_file_name,"w") do |file|
    file.puts fleet_data.to_yaml
  end
  puts "  Generating #{file_name}"
  new_document file_name, fleet_data
