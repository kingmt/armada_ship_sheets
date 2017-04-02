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



  def pill_box args
    save_graphics_state do
        fill_color args[:fill_color]
        corner_rounding = if args[:height] >= 20
                            10
                          else
                            args[:height] * 0.4
                          end
        fill_rounded_rectangle args[:point], args[:width], args[:height], corner_rounding
        fill_color args[:text_color]

        inner_point = [ args[:point][0] + 3, args[:point][1] - 3 ]
        inner_width = args[:width] - 6
        inner_height = args[:height] - 6
        text_box args[:text], at: inner_point,
                              width: inner_width,
                              height: inner_height,
                              align: :center,
                              valign: :center,
                              overflow: :shrink_to_fit
    end
  end

  def title_box ship
    # slice ship name to get section to be italicized
    ship_type = if /(.+)(-class.*)/ =~ ship['ship_type']
                  "<i>#{$1}</i>#{$2}"
                else
                  ship['ship_type']
                end
    font "Engebrechtre", size: 144 do
      text_box ship_type, at: [0,540],
                          width: 720,
                          height: 50,
                          overflow: :shrink_to_fit,
                          inline_format: true,
                          align: :center,
                          valign: :center
    end
  end

  def points_box ship
    bounding_box [0,490], width: 210, height: 40 do
      save_graphics_state do
        stroke_color 'ffffff'
        if ship['flagship']
          pill_box point: [3, 34],
                   fill_color: 'F0B45F',
                   text_color: '000000',
                   height: 30,
                   width: 60,
                   text: "Flagship"
        end

        # points pill
        pill_box point: [65, 34],
                 fill_color: '5F91D2',
                 text_color: 'ffffff',
                 height: 30,
                 width: 70,
                 text: "#{ship['base_points']}\nbase points"
        # upgrade pill
        pill_box point: [137, 34],
                 fill_color: '41B973',
                 text_color: 'ffffff',
                 height: 30,
                 width: 70,
                 text: "+#{ship['upgrade_points']}\nupgrade points"
      end
    end
  end

  def upgrades_box ship
    bounding_box [215,490], width: 505, height: 400 do
      define_grid columns: 4, rows: 2, gutter: 5
      ship['upgrades'].each_with_index do |upgrade, index|
        x = index/4
        y = index % 4
        grid(x, y).bounding_box do
          image upgrade, fit: [125, 200], position: :center, vposition: :center
        end
      end
    end
  end

  def notes_box
    bounding_box [0,85], width: 720, height: 85 do
      lines_table = make_table [ [''],[''],[''] ],
                               cell_style: { #background_color: "F0B45F",
                                             borders: [:bottom],
                                             height: 26 },
                               column_widths: [665]
      notes_table = table [ [{content: 'Notes:', size: 20, font: "McHandwriting"},
                                  lines_table ] ],
                               column_widths: [55, 665],
                               cell_style: { borders: []}
    end
  end

  def generate_ship_pdf_page ship
    title_box ship
    # ship card box
    bounding_box [0,450], width: 210, height: 360 do
      image ship['ship_image'], fit: [210, 360], position: :center, vposition: :center
    end
    points_box ship
    upgrades_box ship
    notes_box
  end

  def generate_squadrons_pdf_page squadrons
    font "Engebrechtre", size: 144 do
      text_box 'Squadrons', at: [0,540], width: 720, height: 50,
                            overflow: :shrink_to_fit,
                            align: :center, valign: :center
    end
    bounding_box [0,490], width: 720, height: 400 do
      define_grid columns: 5, rows: 2, gutter: 5
      squadrons.each_with_index do |squadron, index|
        x = index/5
        y = index % 5
        grid(x, y).bounding_box do
          image squadron['image'], fit: [125, 200], position: :center, vposition: :bottom
          squadron_count_text = if squadron['count'].to_i > 1
                                  "#{squadron['count']} squadrons"
                                else
                                  "#{squadron['count']} squadron"
                                end
          pill_box point: [10, bounds.top - 5], height: 15, width: 55,
                   fill_color: '5F91D2', text_color: 'ffffff',
                   text: squadron_count_text
          pill_box point: [70, bounds.top - 5], height: 15, width: 60,
                   fill_color: '41B973', text_color: 'ffffff',
                   text: "#{squadron['total_cost']} total points"
        end
      end
    end
    notes_box
  end

  def new_document file_name, fleet_data
    Prawn::Document.generate(file_name,
                             :page_size     => "LETTER",
                             :print_scaling => :none,
                             :page_layout   => :landscape) do
      font_families.update "Engebrechtre"  => { :normal => "../fonts/engebrechtre.regular.ttf",
                                                :italic => "../fonts/engebrechtre.italic.ttf",
                                                :bold   => "../fonts/engebrechtre.bold.ttf" },
                           "McHandwriting" => { :normal => "../fonts/McHandwriting.ttf" }


      # generate page for each ship
      # now the fun part is that the first page is automatic
      # pages 2, 3, etc are created by calling 'start_new_page'
      ships = fleet_data['ships']
      first_ship = ships.shift
      generate_ship_pdf_page first_ship

      ships.each do |ship|
        start_new_page
        generate_ship_pdf_page ship
      end

      # # generate page(s) for squadrons
      if fleet_data['squadrons'].count == 0
        # do nothing
      else
        fleet_data['squadrons'].each_slice(10) do |squads|
          start_new_page
          generate_squadrons_pdf_page squads
        end
      end
    end
  end
