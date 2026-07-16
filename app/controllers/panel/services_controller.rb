module Panel
  class ServicesController < BaseController
    def index
      @services = @wash.services.order(:price)
      @service = Service.new
    end

    def create
      @service = @wash.services.new(service_params)
      if @service.save
        redirect_to panel_services_path, notice: "Xizmat qo'shildi"
      else
        redirect_to panel_services_path, alert: @service.errors.full_messages.to_sentence
      end
    end

    def edit
      @service = @wash.services.find(params[:id])
    end

    def update
      @service = @wash.services.find(params[:id])
      if @service.update(service_params)
        redirect_to panel_services_path, notice: "Xizmat yangilandi"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @service = @wash.services.find(params[:id])
      if @service.destroy
        redirect_to panel_services_path, notice: "Xizmat o'chirildi"
      else
        redirect_to panel_services_path,
          alert: "Bu xizmatga bronlar bog'langan, o'chirib bo'lmaydi"
      end
    end

    private

    def service_params
      params.require(:service).permit(:name, :price, :duration_minutes)
    end
  end
end
