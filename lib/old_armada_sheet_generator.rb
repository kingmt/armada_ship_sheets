require "prawn"
require "prawn/measurement_extensions"
require "prawn_shapes"
require "prawn/table"

# Card sizes are:
#   ships 70x120mm
#   upgrades 44x68mm
#
#   72 points per inch
#   25.4 mm per inch
#
#   ships 70/25.4*72 x 120/25.4*72
#         198.4 x 340.2
#   upgrades 44/25.4*72 x 68/25.4*72
#            124.7 x 192.8

  # data
  #ship_type = "<i>Imperial II</i>-class Star Destroyer"
  ship_type = "Imperial II-class Star Destroyer"

  flagship = 'Flagship'
  flagship2 = nil
  base_points = "120\nbase points"
  upgrade_points = "+ 167\nupgrade points"

  ship_image = "/Users/mking/Downloads/Armada/assets/cards/ships/empire/imperial-II.png"
  upgrade_1_image = "/Users/mking/Downloads/Armada/assets/cards/upgrades/chart-officer.png"
  upgrade_2_image = "/Users/mking/Downloads/Armada/assets/cards/upgrades/comms-net.png"
  upgrade_3_image = "/Users/mking/Downloads/Armada/assets/cards/upgrades/engine-techs.png"
  upgrade_4_image = "/Users/mking/Downloads/Armada/assets/cards/upgrades/leading-shots.png"
  upgrade_5_image = "/Users/mking/Downloads/Armada/assets/cards/upgrades/overload-Pulse.png"
  upgrade_6_image = "/Users/mking/Downloads/Armada/assets/cards/upgrades/relentless.png"
  upgrade_7_image = "/Users/mking/Downloads/Armada/assets/cards/upgrades/slaved-turrets.png"
  upgrade_8_image = "/Users/mking/Downloads/Armada/assets/cards/upgrades/cluster-bombs.png"
  upgrades = [ upgrade_1_image,
               upgrade_2_image,
               upgrade_3_image,
               upgrade_4_image,
               upgrade_5_image,
               upgrade_6_image,
               upgrade_7_image,
               upgrade_8_image,
             ]




def points_table flagship, base_points, upgrade_points
  flagship_cell =       make_cell content: flagship,
                                  align: :center,
                                  padding: 0,
                                  background_color: "F0B45F"
  base_points_cell =    make_cell content: base_points,
                                  align: :center,
                                  padding: 0,
                                  background_color: '5F91D2'
  upgrade_points_cell = make_cell content: upgrade_points,
                                  align: :center,
                                  padding: 0,
                                  background_color: '41B973'
  points_data = if flagship
                  [[ flagship_cell, '', base_points_cell, '', upgrade_points_cell ]]
                else
                  [[ base_points_cell, '', upgrade_points_cell ]]
                end
  points_table = make_table points_data,
                 position: :center,
                 cell_style: {text_color: "FFFFFF",
                              size: 9,
                              #borders: [],
                              padding: 1,
                              font: "Engebrechtre",
                              height: 20}

end

def landscape_points_row flagship, base_points, upgrade_points
  [ points_table(flagship, base_points, upgrade_points), '', '' ]
end

def portrait_points_row flagship, base_points, upgrade_points
  [ points_table(flagship, base_points, upgrade_points), '', make_cell({content: 'Notes:', size: 10, font: "Engebrechtre"}) ]
end

def portrait_row_1 ship_image, upgrades
  upgrades_table_2x2 = make_table [ # spacers until I find something better
                                    ['',''], ['',''], ['',''],
                                    ['',''], ['',''],
                                    [ {image: upgrades[0],
                                       position: :center,
                                       vposition: :center,
                                       fit: [125,193]},
                                      {image: upgrades[1],
                                       position: :center,
                                       vposition: :center,
                                       fit: [125,193]}
                                    ],
                                    [
                                      {image: upgrades[2],
                                       position: :center,
                                       vposition: :center,
                                       fit: [125,193]},
                                      {image: upgrades[3],
                                       position: :center,
                                       vposition: :center,
                                       fit: [125,193]}
                                    ]
                                  ],
                                cell_style: {borders: [], inline_format: true}
  [ {image: ship_image,
     position: :center,
     fit: [200, 340]},
    '',
    upgrades_table_2x2]
end

def portrait_row_2 ship_image, upgrades
  upgrades_row_2 = make_table [[ {image: upgrades[4],
                               position: :center,
                               vposition: :center,
                               fit: [125,193]},
                              {image: upgrades[5],
                               position: :center,
                               vposition: :center,
                               fit: [125,193]},
                              {image: upgrades[6],
                               position: :center,
                               vposition: :center,
                               fit: [125,193]},
                              {image: upgrades[7],
                               position: :center,
                               vposition: :center,
                               fit: [125,193]}
                            ]],
        cell_style: {borders: [], inline_format: true}
end

file_name = "../ISD_portrait.pdf"
puts "  Generating #{file_name}"
Prawn::Document.generate(file_name,
                           :page_size   => "LETTER",
                           :print_scaling => :none,
                           :page_layout => :portrait) do
  font_families.update "Pacifico"      => { :normal => "../Pacifico.ttf" },
                       "IceCream Soda" => { :normal => "../ICE-CS__.ttf" },
                       "FFF Tusj"      => { :normal => "../FFF_Tusj.ttf" },
                       "Engebrechtre"  => { :normal => "../engebrechtre.regular.ttf",
                                            :italic => "../engebrechtre.italic.ttf",
                                            :bold   => "../engebrechtre.bold.ttf" },
                       "McHandwriting" => { :normal => "../McHandwriting.ttf" }

  table [ [{ content: ship_type,
            align: :center,
            size: 72,
            overflow: :shrink_to_fit,
            colspan: 3,
            height: 50,
            font: "Engebrechtre" }],
          portrait_points_row(flagship, base_points, upgrade_points),
          portrait_row_1(ship_image, upgrades),
          [{content: portrait_row_2(ship_image, upgrades), colspan: 3}]
          #portrait_row_2(ship_image, upgrades)
        ],
        position: :center,
        cell_style: { #borders: [],
                      inline_format: true},
        #column_widths: [240, 10, 470]
        column_widths: [240, 10, 290]
end

file_name = "../ISD_landscape.pdf"
puts "  Generating #{file_name}"
Prawn::Document.generate(file_name,
                           :page_size   => "LETTER",
                           :print_scaling => :none,
                           :page_layout => :landscape) do
  font_families.update "Pacifico"      => { :normal => "../Pacifico.ttf" },
                       "IceCream Soda" => { :normal => "../ICE-CS__.ttf" },
                       "FFF Tusj"      => { :normal => "../FFF_Tusj.ttf" },
                       "Engebrechtre"  => { :normal => "../engebrechtre.regular.ttf",
                                            :italic => "../engebrechtre.italic.ttf",
                                            :bold   => "../engebrechtre.bold.ttf" },
                       "McHandwriting" => { :normal => "../McHandwriting.ttf" }

  lines_table = make_table [ [''],[''],[''] ],
                           cell_style: { #background_color: "F0B45F",
                                         borders: [:bottom],
                                         height: 26 },
                           column_widths: [665]
                           #column_widths: [665]
  #notes_table = make_table [ [{content: 'Notes:', size: 20, font: "Engebrechtre"},
  notes_table = make_table [ [{content: 'Notes:', size: 20, font: "McHandwriting"},
                              lines_table ] ],
                           column_widths: [55, 665],
                           #column_widths: [55, 665],
                           cell_style: { borders: []}

  upgrades_row_1 = [ {image: upgrades[0],
                      position: :center,
                      vposition: :center,
                      fit: [125,193]},
                     {image: upgrades[1],
                      position: :center,
                      vposition: :center,
                      fit: [125,193]},
                     {image: upgrades[2],
                      position: :center,
                      vposition: :center,
                      fit: [125,193]},
                     {image: upgrades[3],
                      position: :center,
                      vposition: :center,
                      fit: [125,193]}
                   ]
  upgrades_row_2 = [ {image: upgrades[4],
                      position: :center,
                      vposition: :center,
                      fit: [125,193]},
                     {image: upgrades[5],
                      position: :center,
                      vposition: :center,
                      fit: [125,193]},
                     {image: upgrades[6],
                      position: :center,
                      vposition: :center,
                      fit: [125,193]},
                     {image: upgrades[7],
                      position: :center,
                      vposition: :center,
                      fit: [125,193]}
                   ]

  ship_card = {image: ship_image, position: :center, fit: [210, 400]}
  flagship_cell =       make_cell content: flagship,
                                  align: :center,
                                  padding: 0#,
                                #  background_color: "F0B45F"
  base_points_cell =    make_cell content: base_points,
                                  align: :center,
                                  padding: 0#,
                               #   background_color: '5F91D2'
  upgrade_points_cell = make_cell content: upgrade_points,
                                  align: :center,
                                  padding: 0#,
                              #    background_color: '41B973'
  points_data = if flagship
                  [[ flagship_cell, '', base_points_cell, '', upgrade_points_cell ]]
                else
                  [[ base_points_cell, '', upgrade_points_cell ]]
                end
  points_table = make_table points_data,
                 position: :center,
                 #cell_style: {text_color: "FFFFFF",
                 cell_style: {text_color: "000000",
                              size: 9,
                              #borders: [],
                              padding: 3,
                              #font: "Engebrechtre",
                              font: "McHandwriting",
                              height: 30}
  ship_card_cell = make_table [[{content: '', height: 5}],
                               [points_table],
                               [{content: '', height: 5}],
                               [ship_card]],
                              cell_style: { padding: 0}
  upgrades_cell = make_table [ upgrades_row_1, upgrades_row_2 ],
                              position: :center,
                              cell_style: {width: 127,
                                           borders: []}

          #landscape_points_row(flagship, base_points, upgrade_points),
  row_1 = [{ content: ship_type,
             align: :center,
             size: 72,
             overflow: :shrink_to_fit,
             colspan: 2,
             height: 50,
             font: "McHandwriting" }]
             #font: "Engebrechtre" }]
  row_2 = [ ship_card_cell, upgrades_cell ]
  row_3 = [{ content: notes_table, colspan: 2 }]
  table [ row_1,
          row_2,
          row_3
        ],
        position: :center,
        column_widths: [210, 510],
        cell_style: { #borders: [],
                      padding: 0,
                      inline_format: true}
end
