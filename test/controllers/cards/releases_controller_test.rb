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

  test "edit offers to clear the release the card already has" do
    cards(:logo).update!(release: "v1.2")

    get edit_card_release_path(cards(:logo))

    assert_select ".popup__item", text: /Clear release/
  end

  test "update sets the release" do
    patch card_release_path(cards(:logo)), params: { card: { release: "  v1.2  " } }, as: :turbo_stream

    assert_response :success
    assert_equal "v1.2", cards(:logo).reload.release
    assert_includes response.body, dom_id(cards(:logo), :release)
  end

  test "update clears the release when blank" do
    cards(:logo).update!(release: "v1.2")

    patch card_release_path(cards(:logo)), params: { card: { release: "" } }, as: :turbo_stream

    assert_response :success
    assert_nil cards(:logo).reload.release
  end
end
