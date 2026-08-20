require "test_helper"

class FiltersControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as :david
  end

  test "create" do
    assert_difference "users(:david).filters.count", +1 do
      post filters_path, params: {
        indexed_by: "closed",
        assignment_status: "unassigned",
        tag_ids: [ tags(:mobile).id ],
        assignee_ids: [ users(:jz).id ],
        board_ids: [ boards(:writebook).id ] }, as: :turbo_stream
    end
    assert_response :success

    filter = Filter.last
    assert_predicate filter.indexed_by, :closed?
    assert_predicate filter.assignment_status, :unassigned?
    assert_equal [ tags(:mobile) ], filter.tags
    assert_equal [ users(:jz) ], filter.assignees
    assert_equal [ boards(:writebook) ], filter.boards
  end

  test "filter pickers only allow one selection" do
    get board_path(boards(:writebook))

    pickers = css_select(".quick-filter[data-controller~='multi-selection-combobox']")

    assert_predicate pickers, :any?
    assert_select ".quick-filter[data-multi-selection-combobox-single-value='true']", count: pickers.size
  end

  test "destroy" do
    filter = filters(:jz_assignments)
    expected_params = filter.as_params

    assert_difference "users(:david).filters.count", -1 do
      delete filter_path(filter), as: :turbo_stream
    end
    assert_response :success
  end
end
