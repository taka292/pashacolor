import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="map"
export default class extends Controller {
  static values = {
    latitude: Number,
    longitude: Number,
    locationName: String
  }

  connect() {
    // Google Maps APIが読み込まれるまで待つ
    if (typeof google !== 'undefined') {
      this.initializeMap()
    } else {
      // Google Maps APIが読み込まれるまで待機
      window.addEventListener('google-maps-loaded', () => {
        this.initializeMap()
      })
    }
  }

  initializeMap() {
    // 緯度経度が存在しない場合は何もしない
    if (!this.latitudeValue || !this.longitudeValue) {
      console.log('位置情報がありません')
      return
    }

    const position = {
      lat: this.latitudeValue,
      lng: this.longitudeValue
    }

    // マップの初期化
    const map = new google.maps.Map(this.element, {
      center: position,
      zoom: 15,
      mapTypeControl: true,
      streetViewControl: true,
      fullscreenControl: true,
    })

    // マーカーの追加
    const marker = new google.maps.Marker({
      position: position,
      map: map,
      title: this.locationNameValue || '投稿位置',
      animation: google.maps.Animation.DROP,
    })

    // 情報ウィンドウの追加（場所名がある場合）
    if (this.locationNameValue) {
      const infoWindow = new google.maps.InfoWindow({
        content: `<div class="p-2"><strong>${this.locationNameValue}</strong></div>`
      })
      
      marker.addListener('click', () => {
        infoWindow.open(map, marker)
      })
      
      // 初期表示で情報ウィンドウを開く
      infoWindow.open(map, marker)
    }
  }
}

