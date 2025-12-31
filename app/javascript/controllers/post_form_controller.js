import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "selectedColor"]

  connect() {
    // フォーム送信時のバリデーション
    this.formTarget.addEventListener("submit", this.validateColorSelection.bind(this))

    // 初期選択色の設定
    this.initializeSelectedColor()
  }

  // 初期選択色の設定
  initializeSelectedColor() {
    const checkedRadio = this.formTarget.querySelector('input[name="post[color_theme_id]"]:checked')

    if (checkedRadio) {
      // チェックされているラジオボタンがある場合、その色情報を表示
      const colorName = checkedRadio.dataset.postFormColorNameParam
      const colorCode = checkedRadio.dataset.postFormColorCodeParam

      if (colorName && colorCode) {
        const display = this.selectedColorTarget
        const circle = document.getElementById("selected-color-circle")
        const name = document.getElementById("selected-color-name")

        if (circle && name && display) {
          circle.style.backgroundColor = colorCode
          name.textContent = colorName
          display.classList.remove("hidden")
        }
      }
    }
  }

  // 選択された色を更新
  updateSelectedColor(event) {
    const colorName = event.target.dataset.postFormColorNameParam
    const colorCode = event.target.dataset.postFormColorCodeParam

    if (colorName && colorCode) {
      const display = this.selectedColorTarget
      const circle = document.getElementById("selected-color-circle")
      const name = document.getElementById("selected-color-name")

      if (circle && name && display) {
        circle.style.backgroundColor = colorCode
        name.textContent = colorName
        display.classList.remove("hidden")
      }
    }
  }

  // 色の選択を検証
  validateColorSelection(event) {
    const colorThemeId = this.formTarget.querySelector('input[name="post[color_theme_id]"]:checked')
    
    if (!colorThemeId) {
      event.preventDefault()
      alert("色を選択してください")
      return false
    }
  }
}



