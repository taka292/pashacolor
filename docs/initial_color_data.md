# 初期色データ（12色の色相環）

## 概要

ColorThemeテーブルに投入する初期データです。12色の色相環をベースにしています。

## データ定義

### 1. 黄 (Kiiro) - Yellow
- **color_name**: "黄"
- **color_code**: "#FFFF00"
- **rgb_r**: 255
- **rgb_g**: 255
- **rgb_b**: 0
- **display_order**: 1

### 2. 黄緑 (Kimidori) - Yellow-Green
- **color_name**: "黄緑"
- **color_code**: "#ADFF2F"
- **rgb_r**: 173
- **rgb_g**: 255
- **rgb_b**: 47
- **display_order**: 2

### 3. 緑 (Midori) - Green
- **color_name**: "緑"
- **color_code**: "#00FF00"
- **rgb_r**: 0
- **rgb_g**: 255
- **rgb_b**: 0
- **display_order**: 3

### 4. 青緑 (Aomidori) - Blue-Green
- **color_name**: "青緑"
- **color_code**: "#00FFFF"
- **rgb_r**: 0
- **rgb_g**: 255
- **rgb_b**: 255
- **display_order**: 4

### 5. 青 (Ao) - Blue
- **color_name**: "青"
- **color_code**: "#0000FF"
- **rgb_r**: 0
- **rgb_g**: 0
- **rgb_b**: 255
- **display_order**: 5

### 6. 青紫 (Aomurasaki) - Blue-Violet
- **color_name**: "青紫"
- **color_code**: "#8A2BE2"
- **rgb_r**: 138
- **rgb_g**: 43
- **rgb_b**: 226
- **display_order**: 6

### 7. 紫 (Murasaki) - Violet
- **color_name**: "紫"
- **color_code**: "#8000FF"
- **rgb_r**: 128
- **rgb_g**: 0
- **rgb_b**: 255
- **display_order**: 7

### 8. 赤紫 (Akamurasaki) - Red-Violet
- **color_name**: "赤紫"
- **color_code**: "#FF00FF"
- **rgb_r**: 255
- **rgb_g**: 0
- **rgb_b**: 255
- **display_order**: 8

### 9. 赤 (Aka) - Red
- **color_name**: "赤"
- **color_code**: "#FF0000"
- **rgb_r**: 255
- **rgb_g**: 0
- **rgb_b**: 0
- **display_order**: 9

### 10. 赤橙 (Akadaidai) - Red-Orange
- **color_name**: "赤橙"
- **color_code**: "#FF4500"
- **rgb_r**: 255
- **rgb_g**: 69
- **rgb_b**: 0
- **display_order**: 10

### 11. 橙 (Daidai) - Orange
- **color_name**: "橙"
- **color_code**: "#FFA500"
- **rgb_r**: 255
- **rgb_g**: 165
- **rgb_b**: 0
- **display_order**: 11

### 12. 黄橙 (Kidaidai) - Yellow-Orange
- **color_name**: "黄橙"
- **color_code**: "#FFD700"
- **rgb_r**: 255
- **rgb_g**: 215
- **rgb_b**: 0
- **display_order**: 12

## Rails seeds.rb での実装例

```ruby
# db/seeds.rb

colors = [
  { color_name: "黄", color_code: "#FFFF00", rgb_r: 255, rgb_g: 255, rgb_b: 0, display_order: 1 },
  { color_name: "黄緑", color_code: "#ADFF2F", rgb_r: 173, rgb_g: 255, rgb_b: 47, display_order: 2 },
  { color_name: "緑", color_code: "#00FF00", rgb_r: 0, rgb_g: 255, rgb_b: 0, display_order: 3 },
  { color_name: "青緑", color_code: "#00FFFF", rgb_r: 0, rgb_g: 255, rgb_b: 255, display_order: 4 },
  { color_name: "青", color_code: "#0000FF", rgb_r: 0, rgb_g: 0, rgb_b: 255, display_order: 5 },
  { color_name: "青紫", color_code: "#8A2BE2", rgb_r: 138, rgb_g: 43, rgb_b: 226, display_order: 6 },
  { color_name: "紫", color_code: "#8000FF", rgb_r: 128, rgb_g: 0, rgb_b: 255, display_order: 7 },
  { color_name: "赤紫", color_code: "#FF00FF", rgb_r: 255, rgb_g: 0, rgb_b: 255, display_order: 8 },
  { color_name: "赤", color_code: "#FF0000", rgb_r: 255, rgb_g: 0, rgb_b: 0, display_order: 9 },
  { color_name: "赤橙", color_code: "#FF4500", rgb_r: 255, rgb_g: 69, rgb_b: 0, display_order: 10 },
  { color_name: "橙", color_code: "#FFA500", rgb_r: 255, rgb_g: 165, rgb_b: 0, display_order: 11 },
  { color_name: "黄橙", color_code: "#FFD700", rgb_r: 255, rgb_g: 215, rgb_b: 0, display_order: 12 }
]

colors.each do |color_data|
  ColorTheme.find_or_create_by(color_name: color_data[:color_name]) do |color|
    color.color_code = color_data[:color_code]
    color.rgb_r = color_data[:rgb_r]
    color.rgb_g = color_data[:rgb_g]
    color.rgb_b = color_data[:rgb_b]
    color.display_order = color_data[:display_order]
    color.is_active = true
    color.description = "#{color_data[:color_name]}色のお題にチャレンジしましょう！"
  end
end
```


