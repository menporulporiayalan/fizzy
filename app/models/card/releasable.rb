module Card::Releasable
  extend ActiveSupport::Concern

  included do
    normalizes :release, with: -> { it.strip.presence }
  end

  class_methods do
    def releases
      where.not(release: nil).distinct.order(:release).pluck(:release)
    end
  end
end
