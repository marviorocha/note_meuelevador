import { Controller } from "@hotwired/stimulus"
import { highlightSearchTerm } from "highlight-search-term"

// Connects to data-controller="highlight"
export default class extends Controller {
  static values = {
    term: String
  }

  connect() {
    if (this.termValue) {
      highlightSearchTerm({
        search: this.termValue,
        selector: ".prose"
      })
    }
  }
}
