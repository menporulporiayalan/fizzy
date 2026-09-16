require "test_helper"

class Card::ReleasableTest < ActiveSupport::TestCase
  setup do
    @cards = cards(:logo).account.cards
  end

  test "releases lists the most recently used first" do
    release cards(:logo), "v1.0", 3.days.ago
    release cards(:layout), "v1.1", 1.day.ago
    release cards(:text), "v0.9", 2.days.ago

    assert_equal %w[ v1.1 v0.9 v1.0 ], @cards.releases
  end

  test "releases lists a release shared by many cards once, at its latest use" do
    release cards(:logo), "v1.0", 3.days.ago
    release cards(:layout), "v1.1", 2.days.ago
    release cards(:text), "v1.0", 1.day.ago

    assert_equal %w[ v1.0 v1.1 ], @cards.releases
  end

  test "releases skips the cards that aren't in one" do
    release cards(:logo), "v1.0", 1.day.ago

    assert_equal %w[ v1.0 ], @cards.releases
  end

  test "releases pins the one asked for to the top without repeating it" do
    release cards(:logo), "v1.0", 3.days.ago
    release cards(:layout), "v1.1", 1.day.ago

    assert_equal %w[ v1.0 v1.1 ], @cards.releases(first: "v1.0")
  end

  # The release being filtered on may have lost its last card, and you still need to see it.
  test "releases pins one that isn't in use at all" do
    release cards(:logo), "v1.0", 1.day.ago

    assert_equal %w[ v0.1 v1.0 ], @cards.releases(first: "v0.1")
  end

  test "releases ignores a blank pin" do
    release cards(:logo), "v1.0", 1.day.ago

    assert_equal %w[ v1.0 ], @cards.releases(first: nil)
    assert_equal %w[ v1.0 ], @cards.releases(first: "")
  end

  private
    # Bypass callbacks so the "last used" timestamp is exactly what the test says it is.
    def release(card, name, used_at)
      card.update_columns(release: name, updated_at: used_at)
    end
end
