import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Auto-dismiss flash messages after 5 seconds
    setTimeout(() => {
      this.element.classList.add("opacity-0", "transition-opacity", "duration-500")
      setTimeout(() => this.element.remove(), 500)
    }, 5000)
  }

  close() {
    // Allow manual close
    this.element.classList.add("opacity-0", "transition-opacity", "duration-500")
    setTimeout(() => this.element.remove(), 500)
  }
}