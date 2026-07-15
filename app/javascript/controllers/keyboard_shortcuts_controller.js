import { Controller } from "@hotwired/stimulus"



export default class extends Controller {
  static targets = ["form", "deleteButton"]

  connect() {
    this.handleKeydown = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.handleKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleKeydown)
  }

  handleKeydown(event) {
    const isMac = navigator.platform.toUpperCase().indexOf("MAC") >= 0
    const modifierKey = isMac ? event.metaKey : event.ctrlKey

    // Ctrl+S (ou Cmd+S no Mac) -> Salvar
    if (modifierKey && event.key.toLowerCase() === "s") {
      event.preventDefault()
      this.save()
    }

    // Delete -> Deletar (só se não estiver digitando em um input/textarea)
    if (event.key === "Delete" && !this.isTyping(event.target)) {
      event.preventDefault()
      this.destroy()
    }

    // Escape -> Cancelar/Fechar modal (bônus comum)
    if (event.key === "Escape") {
      this.cancel()
    }
  }

  isTyping(target) {
    const tag = target.tagName.toLowerCase()
    return tag === "input" || tag === "textarea" || target.isContentEditable
  }

  save() {
    if (this.hasFormTarget) {
      this.formTarget.requestSubmit()
    }
  }

  destroy() {
    if (this.hasDeleteButtonTarget) {
      if (confirm("Tem certeza que deseja deletar esta nota?")) {
        this.deleteButtonTarget.click()
      }
    }
  }

  cancel() {
    const cancelLink = this.element.querySelector('[data-keyboard-shortcuts-target="cancelLink"]')
    if (cancelLink) cancelLink.click()
  }
}
