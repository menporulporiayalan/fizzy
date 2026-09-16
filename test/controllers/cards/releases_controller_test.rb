require "test_helper"

class Cards::ReleasesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as :kevin
  end

  test "edit lists the releases already in use" do
    cards(:layout).update!(release: "v1.2")

    get edit_card_release_path(cards(:logo))

    assert_response :success
    assert_select ".popup__item", text: /v1\.2/
  end

  test "edit lists the most recently used releases first" do
    cards(:layout).update_columns(release: "v1.2", updated_at: 3.days.ago)
    cards(:text).update_columns(release: "v1.3", updated_at: 1.day.ago)

    get edit_card_release_path(cards(:logo))

    assert_equal %w[ v1.3 v1.2 ], css_select(".popup__item[role=checkbox] .overflow-ellipsis").map(&:text)
  end

  # The card's own release may be older than the ones the picker lists by default.
  test "edit lists the release the card is in first" do
    cards(:logo).update_columns(release: "v1.2", updated_at: 3.days.ago)
    cards(:layout).update_columns(release: "v1.3", updated_at: 1.day.ago)

    get edit_card_release_path(cards(:logo))

    assert_equal %w[ v1.2 v1.3 ], css_select(".popup__item[role=checkbox] .overflow-ellipsis").map(&:text)
  end

  test "edit checks the release the card is already in, and offers to clear it" do
    cards(:logo).update!(release: "v1.2")

    get edit_card_release_path(cards(:logo))

    assert_select ".popup__item[role=checkbox][aria-checked=true]", text: /v1\.2/ do
      assert_select "input[name=_method][value=delete]"
    end
  end

  test "edit offers to set a release the card isn't in" do
    cards(:layout).update!(release: "v1.2")

    get edit_card_release_path(cards(:logo))

    assert_select ".popup__item[role=checkbox][aria-checked=false]", text: /v1\.2/ do
      assert_select "input[name=_method][value=delete]", count: 0
    end
  end

  test "update sets the release" do
    patch card_release_path(cards(:logo)), params: { card: { release: "  v1.2  " } }, as: :turbo_stream

    assert_response :success
    assert_equal "v1.2", cards(:logo).reload.release
    assert_includes response.body, dom_id(cards(:logo), :release)
  end

  # Setting is idempotent: the picker's free-text field and a retried request
  # both land here, and neither may clear what it just asked for.
  test "update re-setting the release the card is already in leaves it alone" do
    cards(:logo).update!(release: "v1.2")

    patch card_release_path(cards(:logo)), params: { card: { release: "  v1.2  " } }, as: :turbo_stream

    assert_response :success
    assert_equal "v1.2", cards(:logo).reload.release
  end

  test "update replaces a release with a different one" do
    cards(:logo).update!(release: "v1.2")

    patch card_release_path(cards(:logo)), params: { card: { release: "v1.3" } }, as: :turbo_stream

    assert_response :success
    assert_equal "v1.3", cards(:logo).reload.release
  end

  test "update clears the release when blank" do
    cards(:logo).update!(release: "v1.2")

    patch card_release_path(cards(:logo)), params: { card: { release: "" } }, as: :turbo_stream

    assert_response :success
    assert_nil cards(:logo).reload.release
  end

  test "destroy clears the release" do
    cards(:logo).update!(release: "v1.2")

    delete card_release_path(cards(:logo)), as: :turbo_stream

    assert_response :success
    assert_nil cards(:logo).reload.release
    assert_includes response.body, dom_id(cards(:logo), :release)
  end

  test "destroy answers no content for JSON" do
    cards(:logo).update!(release: "v1.2")

    delete card_release_path(cards(:logo)), as: :json

    assert_response :no_content
    assert_nil cards(:logo).reload.release
  end
end
