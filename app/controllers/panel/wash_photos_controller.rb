module Panel
  class WashPhotosController < BaseController
    def create
      if params[:photos].present?
        @wash.photos.attach(params[:photos])
        redirect_to edit_panel_wash_path, notice: "Rasmlar yuklandi"
      else
        redirect_to edit_panel_wash_path, alert: "Rasm tanlanmadi"
      end
    end

    def destroy
      @wash.photos.find(params[:id]).purge
      redirect_to edit_panel_wash_path, notice: "Rasm o'chirildi"
    end
  end
end
