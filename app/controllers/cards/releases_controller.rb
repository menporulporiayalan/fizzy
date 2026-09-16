class Cards::ReleasesController < ApplicationController
  include CardScoped

  def edit
    @releases = Current.account.cards.releases(first: @card.release)
    fresh_when etag: [ @releases, @card.release ]
  end

  def update
    @card.update!(release: release_params)
    render_release
  end

  def destroy
    @card.update!(release: nil)
    render_release
  end

  private
    def release_params
      params.require(:card).permit(:release)[:release]
    end

    def render_release
      respond_to do |format|
        format.turbo_stream { render :update }
        format.json { head :no_content }
      end
    end
end
