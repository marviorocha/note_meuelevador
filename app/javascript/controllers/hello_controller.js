import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        this.element.textContent = "Fazendo algo com Stimulus e Vite!"
    }
}
