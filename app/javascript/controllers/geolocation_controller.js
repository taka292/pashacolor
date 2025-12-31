import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["latitudeField", "longitudeField", "gpsDisplay", "latitude", "longitude"]

  // GPS座標を取得
  getCurrentPosition(event) {
    event.preventDefault()

    if (!navigator.geolocation) {
      alert("このブラウザは位置情報をサポートしていません")
      return
    }

    const button = event.currentTarget
    button.disabled = true
    button.textContent = "取得中..."

    navigator.geolocation.getCurrentPosition(
      (position) => {
        const lat = position.coords.latitude
        const lng = position.coords.longitude

        // フォームフィールドに値を設定
        this.latitudeFieldTarget.value = lat
        this.longitudeFieldTarget.value = lng

        // 表示を更新
        this.latitudeTarget.textContent = lat.toFixed(7)
        this.longitudeTarget.textContent = lng.toFixed(7)
        this.gpsDisplayTarget.classList.remove("hidden")

        button.disabled = false
        button.textContent = "📍 現在地を取得"
      },
      (error) => {
        let errorMessage = "位置情報の取得に失敗しました"
        switch (error.code) {
          case error.PERMISSION_DENIED:
            errorMessage = "位置情報の使用が拒否されました"
            break
          case error.POSITION_UNAVAILABLE:
            errorMessage = "位置情報が利用できません"
            break
          case error.TIMEOUT:
            errorMessage = "位置情報の取得がタイムアウトしました"
            break
        }
        alert(errorMessage)

        button.disabled = false
        button.textContent = "📍 現在地を取得"
      },
      {
        enableHighAccuracy: true,
        timeout: 10000,
        maximumAge: 0
      }
    )
  }
}

