# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# ColorThemeマスタデータ（12色の色相環）
color_themes = [
  { color_name: "黄", color_code: "#FFFF00", description: "明るく輝く黄色", display_order: 1 },
  { color_name: "黄緑", color_code: "#80FF00", description: "新緑のような黄緑色", display_order: 2 },
  { color_name: "緑", color_code: "#00FF00", description: "鮮やかな緑色", display_order: 3 },
  { color_name: "青緑", color_code: "#00FF80", description: "海のような青緑色", display_order: 4 },
  { color_name: "青", color_code: "#0080FF", description: "空のような青色", display_order: 5 },
  { color_name: "青紫", color_code: "#8000FF", description: "深みのある青紫色", display_order: 6 },
  { color_name: "紫", color_code: "#FF00FF", description: "神秘的な紫色", display_order: 7 },
  { color_name: "赤紫", color_code: "#FF0080", description: "情熱的な赤紫色", display_order: 8 },
  { color_name: "赤", color_code: "#FF0000", description: "情熱的な赤色", display_order: 9 },
  { color_name: "赤橙", color_code: "#FF4000", description: "温かみのある赤橙色", display_order: 10 },
  { color_name: "橙", color_code: "#FF8000", description: "明るい橙色", display_order: 11 },
  { color_name: "黄橙", color_code: "#FFC000", description: "太陽のような黄橙色", display_order: 12 }
]

color_themes.each do |color_theme_data|
  ColorTheme.find_or_create_by!(display_order: color_theme_data[:display_order]) do |ct|
    ct.color_name = color_theme_data[:color_name]
    ct.color_code = color_theme_data[:color_code]
    ct.description = color_theme_data[:description]
    ct.is_active = true
  end
end

puts "ColorThemeマスタデータを投入しました（#{ColorTheme.count}件）"
