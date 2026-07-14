import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["category", "subcategory", "newSubcategoryWrapper", "newSubcategoryInput"]

  connect() {
    this.filter()
  }

  filter() {
    const categoryId = this.categoryTarget.value
    const options = this.subcategoryTarget.querySelectorAll("option[data-category-id]")

    options.forEach((option) => {
      const matches = !categoryId || option.dataset.categoryId === categoryId
      option.hidden = !matches
      option.disabled = !matches
    })

    const selectedOption = this.subcategoryTarget.selectedOptions[0]
    if (selectedOption && selectedOption.disabled) {
      this.subcategoryTarget.value = ""
    }
  }

  toggleNewSubcategory() {
    this.newSubcategoryWrapperTarget.classList.toggle("hidden")

    // se abriu o campo, desabilita o select (pra não mandar os dois preenchidos)
    const isHidden = this.newSubcategoryWrapperTarget.classList.contains("hidden")
    this.subcategoryTarget.disabled = !isHidden

    if (!isHidden) {
      this.newSubcategoryInputTarget.value = ""
      this.newSubcategoryInputTarget.focus()
    } else {
      this.subcategoryTarget.value = ""
    }
  }
}
