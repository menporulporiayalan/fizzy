class SearchesController < ApplicationController
  include Turbo::DriveHelper

  def show
    @query = params[:q].blank? ? nil : params[:q]

    if card = find_card(@query)
      respond_to do |format|
        format.html { @card = card }
        format.json { set_page_and_extract_portion_from Current.user.accessible_cards.where(id: card.id) }
      end
    else
      respond_to do |format|
        format.html do
          set_page_and_extract_portion_from Current.user.search(@query)
          @recent_search_queries = Current.user.search_queries.order(updated_at: :desc).limit(10)
        end

        format.json do
          set_page_and_extract_portion_from \
            Current.user.accessible_cards.mentioning(@query, user: Current.user).distinct.latest.preloaded
        end
      end
    end
  end

  private
    def find_card(query)
      if by_number = Current.user.accessible_cards.numbered(query)
        by_number.first
      else
        Current.user.accessible_cards.find_by_id(query)
      end
    end
end
