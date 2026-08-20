class Cards::ReleasesController < ApplicationController
  include CardScoped

  def edit
    @releases = Current.account.cards.releases
    fresh_when etag: [ @releases, @card.release ]
  end

  def update
    @card.update!(release: release_params)

    respond_to do |format|
      format.turbo_stream
      format.json { head :no_content }
    end
  end

  private
    def release_params
      params.require(:card).permit(:release)[:release]
    end
end
