import { Controller } from "@hotwired/stimulus"

// "Eng yaqin moyka" tugmasi — brauzer joylashuvini so'rab, formani qayta yuboradi.
export default class extends Controller {
  static targets = [ "lat", "lng", "form", "status" ]
  static values = { locating: String, unsupported: String, denied: String }

  locate() {
    if (!navigator.geolocation) {
      this.showStatus(this.unsupportedValue)
      return
    }
    this.showStatus(this.locatingValue)
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        this.latTarget.value = pos.coords.latitude
        this.lngTarget.value = pos.coords.longitude
        this.formTarget.requestSubmit()
      },
      () => this.showStatus(this.deniedValue),
      { timeout: 8000 }
    )
  }

  showStatus(text) {
    if (this.hasStatusTarget) this.statusTarget.textContent = text
  }
}
