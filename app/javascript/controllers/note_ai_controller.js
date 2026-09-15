import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String
  }

  static targets = [
    "button",
    "buttonText",
    "icon",
    "content",
    "category",
    "subcategory",
    "newSubcategoryInput"
  ]

  async generate(event) {
    if (event) event.preventDefault()

    const categoryId = this.hasCategoryTarget ? this.categoryTarget.value : ""
    const categoryName = (categoryId && this.hasCategoryTarget && this.categoryTarget.selectedIndex >= 0)
      ? this.categoryTarget.options[this.categoryTarget.selectedIndex]?.text
      : ""

    const newSubcategoryName = this.hasNewSubcategoryInputTarget
      ? this.newSubcategoryInputTarget.value.trim()
      : ""

    const subcategoryId = this.hasSubcategoryTarget ? this.subcategoryTarget.value : ""
    const subcategoryName = (subcategoryId && this.hasSubcategoryTarget && this.subcategoryTarget.selectedIndex >= 0)
      ? this.subcategoryTarget.options[this.subcategoryTarget.selectedIndex]?.text
      : ""

    if (!categoryId && !subcategoryId && !newSubcategoryName) {
      alert("Por favor, selecione uma Categoria ou Subcategoria antes de gerar a nota com IA.")
      if (this.hasCategoryTarget) this.categoryTarget.focus()
      return
    }

    if (this.hasContentTarget && this.contentTarget.value.trim().length > 0) {
      const confirmed = window.confirm("O campo de conteúdo já possui texto. Deseja substituí-lo pela nota gerada por IA?")
      if (!confirmed) return
    }

    const originalText = this.hasButtonTextTarget ? this.buttonTextTarget.textContent : "Escrever Nota com IA"

    this.setLoading(true)

    try {
      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content")

      const payload = {
        category_id: categoryId,
        category_name: categoryName,
        subcategory_id: subcategoryId,
        subcategory_name: subcategoryName,
        new_subcategory_name: newSubcategoryName
      }

      const response = await fetch(this.urlValue || "/ai/generate_note", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-CSRF-Token": csrfToken || ""
        },
        body: JSON.stringify(payload)
      })

      const data = await response.json()

      if (!response.ok) {
        throw new Error(data.error || "Não foi possível gerar a nota com IA.")
      }

      if (this.hasContentTarget && data.content) {
        this.contentTarget.value = data.content
        this.contentTarget.dispatchEvent(new Event("input", { bubbles: true }))
        this.contentTarget.dispatchEvent(new Event("change", { bubbles: true }))
        this.contentTarget.focus()
      }

      if (this.hasButtonTextTarget) {
        this.buttonTextTarget.textContent = "Nota gerada com sucesso!"
      }

      setTimeout(() => {
        this.resetButton(originalText)
      }, 2500)
    } catch (error) {
      alert(`Erro: ${error.message}`)
      this.resetButton(originalText)
    }
  }

  setLoading(isLoading) {
    if (this.hasButtonTarget) {
      this.buttonTarget.disabled = isLoading
    }

    if (this.hasIconTarget) {
      if (isLoading) {
        this.iconTarget.classList.add("animate-spin")
      } else {
        this.iconTarget.classList.remove("animate-spin")
      }
    }

    if (this.hasButtonTextTarget && isLoading) {
      this.buttonTextTarget.textContent = "Gerando nota técnica..."
    }
  }

  resetButton(text) {
    this.setLoading(false)
    if (this.hasButtonTextTarget) {
      this.buttonTextTarget.textContent = text
    }
  }
}
