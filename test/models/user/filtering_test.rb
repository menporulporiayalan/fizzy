require "test_helper"

class User::FilteringTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:david)
  end

  # Filter#cards is scoped to published cards, so a release only reachable from a
  # draft would sit in the dropdown matching nothing.
  test "releases skips releases only used by drafts" do
    cards(:layout).update!(release: "v1.2")
    cards(:layout).board.cards.create!(status: "drafted", creator: users(:david), release: "v9.9")

    assert_equal [ "v1.2" ], filtering.releases
  end

  test "releases lists the most recently used first" do
    cards(:logo).update_columns(release: "v1.2", updated_at: 3.days.ago)
    cards(:layout).update_columns(release: "v1.3", updated_at: 1.day.ago)

    assert_equal %w[ v1.3 v1.2 ], filtering.releases
  end

  # The release being filtered on may be older than the ones the dropdown lists by default.
  test "releases pins the one being filtered on to the top" do
    cards(:logo).update_columns(release: "v1.2", updated_at: 3.days.ago)
    cards(:layout).update_columns(release: "v1.3", updated_at: 1.day.ago)

    assert_equal %w[ v1.2 v1.3 ], filtering(filter: filter(release: "v1.2")).releases
  end

  test "users only offers people with access to the boards in play" do
    assert_equal [ users(:david), users(:jz), users(:kevin) ], filtering.users
  end

  test "users narrows to the pinned board" do
    boards(:private).accesses.create!(user: users(:david))

    assert_equal [ users(:david), users(:kevin) ], filtering(board: boards(:private)).users
  end

  test "users narrows to the boards picked in the filter" do
    boards(:private).accesses.create!(user: users(:david))

    assert_equal [ users(:david), users(:kevin) ], filtering(filter: filter(board_ids: [ boards(:private).id ])).users
  end

  test "users keeps whoever is already picked, even without access to those boards" do
    assert_includes filtering(filter: filter(creator_ids: [ users(:jason).id ])).users, users(:jason)
  end

  private
    def filtering(filter: filter(), board: nil)
      User::Filtering.new(users(:david), filter, board: board)
    end

    def filter(**params)
      users(:david).filters.new(**params)
    end
end
