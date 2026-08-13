import { Controller } from "@hotwired/stimulus"

// "Eng yaqin moyka" tugmasi — brauzer joylashuvini so'rab, formani qayta yuboradi.
export default class extends Controller {
  static targets = [ "lat", "lng", "form", "status" ]

  locate() {
    if (!navigator.geolocation) {
      this.showStatus("Brauzeringiz joylashuvni aniqlay olmaydi")
      return
    }
    this.showStatus("Joylashuv aniqlanmoqda...")
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        this.latTarget.value = pos.coords.latitude
        this.lngTarget.value = pos.coords.longitude
        this.formTarget.requestSubmit()
      },
      () => this.showStatus("Joylashuvga ruxsat berilmadi — qo'lda tuman tanlang"),
      { timeout: 8000 }
    )
  }

  showStatus(text) {
    if (this.hasStatusTarget) this.statusTarget.textContent = text
  }
}
