import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["drawer", "menuIcon", "closeIcon", "toggle"]
  
  connect() {
    // コントローラーが接続されたときに実行
  }
  
  toggle() {
    if (this.drawerTarget.classList.contains("hidden")) {
      this.open()
    } else {
      this.close()
    }
  }
  
  open() {
    this.drawerTarget.classList.remove("hidden")
    this.menuIconTarget.classList.add("hidden")
    this.closeIconTarget.classList.remove("hidden")
    this.toggleTarget.setAttribute("aria-expanded", "true")
    document.body.style.overflow = "hidden"
  }
  
  close() {
    this.drawerTarget.classList.add("hidden")
    this.menuIconTarget.classList.remove("hidden")
    this.closeIconTarget.classList.add("hidden")
    this.toggleTarget.setAttribute("aria-expanded", "false")
    document.body.style.overflow = ""
  }
  
  closeOnBackdrop(event) {
    if (event.target === this.drawerTarget) {
      this.close()
    }
  }
  
  closeOnEscape(event) {
    if (event.key === "Escape" && !this.drawerTarget.classList.contains("hidden")) {
      this.close()
    }
  }
}





