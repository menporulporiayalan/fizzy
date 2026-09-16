require "application_system_test_case"

class ReleasePickerTest < ApplicationSystemTestCase
  setup do
    sign_in_as(users(:david))
    Current.user = users(:david)
  end

  test "the picker lists the newest releases and searches for the rest" do
    create_releases 8
    visit card_url(cards(:logo))
    open_release_picker

    assert_releases %w[ v0 v1 v2 v3 v4 ]

    search_releases "v7"
    assert_releases %w[ v7 ]

    search_releases ""
    assert_releases %w[ v0 v1 v2 v3 v4 ]
  end

  test "the picker lists the release the card is in, however old it is" do
    create_releases 8
    cards(:logo).update_columns(release: "v7", updated_at: 1.year.ago)
    visit card_url(cards(:logo))
    open_release_picker

    assert_releases %w[ v7 v0 v1 v2 v3 ]
  end

  # The check used to be painted over the end of the release it marks.
  test "the check on the picked release clears its label" do
    create_releases 2
    cards(:logo).update_columns(release: "v0")
    visit card_url(cards(:logo))
    open_release_picker

    row = find(".popup__item[aria-checked=true]")

    assert_operator left_edge_of(row.find(".checked")), :>=, right_edge_of(row.find(".overflow-ellipsis"))
  end

  private
    def create_releases(count)
      count.times do |index|
        card = cards(:logo).board.cards.create!(title: "Shipped #{index}", creator: users(:david), status: :published)
        card.update_columns(release: "v#{index}", updated_at: index.minutes.ago)
      end
    end

    def open_release_picker
      find(".card__release-button").click
      assert_selector ".popup__title", text: "Released in"
    end

    def search_releases(query)
      within(".popup") { find("input[name='card[release]']").set(query) }
    end

    # Filtering is debounced, so wait for the list to settle before reading it.
    def assert_releases(names)
      assert_selector ".popup__item[role=checkbox]", count: names.size
      assert_equal names, all(".popup__item[role=checkbox] .overflow-ellipsis").map(&:text)
    end

    def left_edge_of(element)
      page.evaluate_script("arguments[0].getBoundingClientRect().left", element)
    end

    def right_edge_of(element)
      page.evaluate_script("arguments[0].getBoundingClientRect().right", element)
    end
end
