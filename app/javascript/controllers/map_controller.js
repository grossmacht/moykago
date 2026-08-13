import { Controller } from "@hotwired/stimulus"

// Leaflet + OpenStreetMap orqali moykalar joylashuvini xaritada ko'rsatadi.
// Leaflet global <script> tegi orqali yuklanadi (importmap ESM qo'llamaydi).
export default class extends Controller {
  static values = { markers: Array, zoom: { type: Number, default: 12 } }

  connect() {
    if (typeof L === "undefined" || this.markersValue.length === 0) return

    const map = L.map(this.element).setView(
      [ this.markersValue[0].lat, this.markersValue[0].lng ],
      this.zoomValue
    )
    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: "&copy; OpenStreetMap"
    }).addTo(map)

    this.markersValue.forEach((m) => {
      const marker = L.marker([ m.lat, m.lng ]).addTo(map)
      if (m.name) marker.bindPopup(m.url ? `<a href="${m.url}">${m.name}</a>` : m.name)
    })

    if (this.markersValue.length > 1) {
      const bounds = L.latLngBounds(this.markersValue.map((m) => [ m.lat, m.lng ]))
      map.fitBounds(bounds, { padding: [ 30, 30 ] })
    }
  }
}
