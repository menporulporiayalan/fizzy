class User::Filtering
  attr_reader :user, :filter, :board, :expanded

  delegate :as_params, :single_board, to: :filter
  delegate :only_closed?, to: :filter

  # +board+ pins the filtering to a single board on pages that are already scoped
  # to one, before any board has been picked in the filter itself.
  def initialize(user, filter, board: nil, expanded: false)
    @user, @filter, @board, @expanded = user, filter, board, expanded
  end

  def boards
    @boards ||= user.boards.ordered_by_recently_accessed
  end

  def selected_board_titles
    filter.board_titles
  end

  def selected_boards_label
    filter.boards_label
  end

  def tags
    @tags ||= account.tags.all.alphabetically
  end

  def users
    @users ||= begin
      people = account.users.active.alphabetically
      people.with_access_to(filtered_boards).or(people.where(id: selected_user_ids))
    end
  end

  def releases
    # Only the releases the index can actually match — Filter#cards is scoped to published cards.
    @releases ||= account.cards.published.releases(first: filter.release)
  end

  def filters
    @filters ||= user.filters.all
  end

  def expanded?
    @expanded
  end

  def any?
    filter.used?(ignore_boards: true)
  end

  def show_indexed_by?
    !filter.indexed_by.all?
  end

  def show_sorted_by?
    !filter.sorted_by.latest?
  end

  def show_tags?
    return unless Tag.any?
    filter.tags.any?
  end

  def show_release?
    filter.release.present?
  end

  def show_assignees?
    filter.assignees.any?
  end

  def show_creators?
    filter.creators.any?
  end

  def show_closers?
    filter.closers.any?
  end

  def show_boards?
    filter.boards.any?
  end

  def single_board_or_first
    # Default to the first selected or, when no selection, to the first one
    filter.boards.first || boards.first
  end

  def cache_key
    ActiveSupport::Cache.expand_cache_key([ user, filter, expanded?, boards, tags, users, releases, filters ], "user-filtering")
  end

  private
    # People are only pickable on the boards being filtered — the account roster is
    # far wider than a board's access list.
    def filtered_boards
      filter.boards.presence || board || user.boards
    end

    # Keep whoever is already selected in the list, so narrowing the boards never
    # silently drops a selection from the form.
    def selected_user_ids
      filter.assignees.ids | filter.creators.ids | filter.closers.ids
    end

    def account
      user.account
    end
end
