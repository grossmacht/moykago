module Panel
  class WashesController < BaseController
    def edit
    end

    def update
      if @wash.update(wash_params)
        redirect_to edit_panel_wash_path, notice: "Ma'lumotlar saqlandi"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def wash_params
      params.require(:wash).permit(
        :name, :district, :address, :phone, :description,
        :open_hour, :close_hour, :bays
      )
    end
  end
end
