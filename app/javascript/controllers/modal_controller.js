import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Prevent scrolling on the body when modal is open
    document.body.classList.add("overflow-hidden")
  }

  disconnect() {
    // Re-enable scrolling on the body when modal is closed
    document.body.classList.remove("overflow-hidden")
  }

  close() {
    this.element.closest("turbo-frame").src = null
    this.element.remove()
  }

  // Handle click outside modal to close
  clickOutside(event) {
    if (event.target === this.element) {
      this.close()
    }
  }
}
