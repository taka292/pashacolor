# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# パレット作成
palettes_data = [
  { name: "基本パレット", description: "色相環の基本となる12色。色を学ぶ第一歩に最適です。", display_order: 1 },
  { name: "宝石パレット", description: "ダイヤモンドやルビー、サファイアのような宝石のような美しい色を集めましょう。", display_order: 2 },
  { name: "花のパレット", description: "桜やバラ、チューリップのような花の繊細で美しい色を集めましょう。", display_order: 3 }
]

palettes_data.each do |data|
  ColorPalette.find_or_create_by!(display_order: data[:display_order]) do |cp|
    cp.name = data[:name]
    cp.description = data[:description]
  end
end

# 色データ作成
color_themes_data = [
  # 基本パレット
  { palette_name: "基本パレット", color_name: "黄", color_code: "#FFFF00", description: "明るく輝く黄色", display_order: 1 },
  { palette_name: "基本パレット", color_name: "黄緑", color_code: "#80FF00", description: "新緑のような黄緑色", display_order: 2 },
  { palette_name: "基本パレット", color_name: "緑", color_code: "#00FF00", description: "鮮やかな緑色", display_order: 3 },
  { palette_name: "基本パレット", color_name: "青緑", color_code: "#00FF80", description: "海のような青緑色", display_order: 4 },
  { palette_name: "基本パレット", color_name: "青", color_code: "#0080FF", description: "空のような青色", display_order: 5 },
  { palette_name: "基本パレット", color_name: "青紫", color_code: "#8000FF", description: "深みのある青紫色", display_order: 6 },
  { palette_name: "基本パレット", color_name: "紫", color_code: "#FF00FF", description: "神秘的な紫色", display_order: 7 },
  { palette_name: "基本パレット", color_name: "赤紫", color_code: "#FF0080", description: "情熱的な赤紫色", display_order: 8 },
  { palette_name: "基本パレット", color_name: "赤", color_code: "#FF0000", description: "情熱的な赤色", display_order: 9 },
  { palette_name: "基本パレット", color_name: "赤橙", color_code: "#FF4000", description: "温かみのある赤橙色", display_order: 10 },
  { palette_name: "基本パレット", color_name: "橙", color_code: "#FF8000", description: "明るい橙色", display_order: 11 },
  { palette_name: "基本パレット", color_name: "黄橙", color_code: "#FFC000", description: "太陽のような黄橙色", display_order: 12 },

  # 宝石パレット
  { palette_name: "宝石パレット", color_name: "ダイヤモンド", color_code: "#E8F4FD", description: "透明感のある輝く白", display_order: 1 },
  { palette_name: "宝石パレット", color_name: "ルビー", color_code: "#DC143C", description: "情熱的な深紅", display_order: 2 },
  { palette_name: "宝石パレット", color_name: "サファイア", color_code: "#0F52BA", description: "深い青の輝き", display_order: 3 },
  { palette_name: "宝石パレット", color_name: "エメラルド", color_code: "#046307", description: "深みのある緑", display_order: 4 },
  { palette_name: "宝石パレット", color_name: "アメジスト", color_code: "#9966CC", description: "神秘的な紫", display_order: 5 },
  { palette_name: "宝石パレット", color_name: "トパーズ", color_code: "#FFC87C", description: "黄金色の輝き", display_order: 6 },
  { palette_name: "宝石パレット", color_name: "オパール", color_code: "#F8F8FF", description: "柔らかな白", display_order: 7 },
  { palette_name: "宝石パレット", color_name: "ターコイズ", color_code: "#30D5C8", description: "鮮やかな青緑", display_order: 8 },

  # 花のパレット
  { palette_name: "花のパレット", color_name: "桜", color_code: "#FFB7C5", description: "淡い桜色", display_order: 1 },
  { palette_name: "花のパレット", color_name: "チューリップ", color_code: "#FF6B9D", description: "鮮やかな赤", display_order: 2 },
  { palette_name: "花のパレット", color_name: "バラ", color_code: "#DC143C", description: "深紅のバラ", display_order: 3 },
  { palette_name: "花のパレット", color_name: "ひまわり", color_code: "#FFD700", description: "輝く黄金", display_order: 4 },
  { palette_name: "花のパレット", color_name: "薔薇", color_code: "#FFB6C1", description: "優しいピンク", display_order: 5 },
  { palette_name: "花のパレット", color_name: "ラベンダー", color_code: "#E6E6FA", description: "淡い紫", display_order: 6 },
  { palette_name: "花のパレット", color_name: "ユリ", color_code: "#FFFFFF", description: "純粋な白", display_order: 7 },
  { palette_name: "花のパレット", color_name: "朝顔", color_code: "#4169E1", description: "爽やかな青", display_order: 8 }
]

color_themes_data.each do |data|
  palette = ColorPalette.find_by!(name: data[:palette_name])
  ColorTheme.find_or_create_by!(color_palette: palette, display_order: data[:display_order]) do |ct|
    ct.color_name = data[:color_name]
    ct.color_code = data[:color_code]
    ct.description = data[:description]
    ct.is_active = true
  end
end

puts "ColorPaletteデータを投入しました（#{ColorPalette.count}件）"
puts "ColorThemeデータを投入しました（#{ColorTheme.count}件）"
