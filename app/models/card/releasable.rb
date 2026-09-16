module Card::Releasable
  extend ActiveSupport::Concern

  # How many releases a picker lists before you have to search for the rest.
  SHOWN_BY_DEFAULT = 5

  included do
    normalizes :release, with: -> { it.strip.presence }
  end

  class_methods do
    # Most recently used first: setting a release touches its cards, so a release just
    # created sorts above ones that have sat untouched for weeks. Pass `first` to pin a
    # release to the top, so the one already picked stays visible in a truncated list.
    def releases(first: nil)
      releases = where.not(release: nil).group(:release).order(Arel.sql("MAX(updated_at) DESC")).pluck(:release)

      if first.present?
        [ first, *releases - [ first ] ]
      else
        releases
      end
    end
  end

  def released_in?(name)
    release == self.class.normalize_value_for(:release, name)
  end
end
