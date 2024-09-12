import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="replace-kanji"
export default class extends Controller {
  static targets = [ "cat", "kanji" ]

  connect(event) {
    console.log("Connected")
  }

  replace(event) {

    const categories = {
      Japanese: "和食",
      Sushi: "寿司",
      Ramen: "ラーメン",
      Yakitori: "焼き鳥",
      Chinese: "中華",
      Italian: "イタリアン",
      Curry: "カレー",
      Izakaya: "居酒屋",
    };

    console.log(this.catTarget.value)
    const selectedCategory = this.catTarget.value
    const kanji = categories[selectedCategory]
    this.kanjiTarget.value = kanji
    console.log(kanji)
}
}
