import { Controller } from "@hotwired/stimulus"
import { debounce } from "helpers/timing_helpers"
import { filterMatches } from "helpers/text_helpers"

export default class extends Controller {
  static targets = [ "input", "item" ]
  static values = { limit: Number }

  initialize() {
    this.filter = debounce(this.filter.bind(this), 100)
  }

  connect() {
    if (this.hasLimitValue) { this.#show("") }
  }

  filter() {
    this.#show(this.inputTarget.value)
    this.dispatch("changed")
  }

  clearInput() {
    if (!this.hasInputTarget) return

    this.inputTarget.value = ""
    this.#show("")
  }

  // Private
    // A long list is unscannable, so lists that set a limit collapse to it until a
    // search reaches past the collapsed items.
    #show(query) {
      if (this.hasLimitValue && query.trim().length === 0) {
        this.itemTargets.forEach((item, index) => item.toggleAttribute("hidden", index >= this.limitValue))
      } else {
        this.itemTargets.forEach(item => item.toggleAttribute("hidden", !filterMatches(item.textContent, query)))
      }
    }
}
