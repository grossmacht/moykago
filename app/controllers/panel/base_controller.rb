module Panel
  class BaseController < ApplicationController
    before_action :require_owner
    before_action :set_wash

    private

    def set_wash
      @wash = current_user.wash
      unless @wash
        redirect_to root_path, alert: "Sizga moyka biriktirilmagan"
      end
    end
  end
end
