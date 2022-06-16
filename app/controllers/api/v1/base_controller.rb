class Api::V1::BaseController < Api::BaseController

    private

    def api_success(status, msg, data)
      render json: { data: data, type: 'Success', status: status, message: msg }
    end

    def api_error(status, errors)
      render json: { data: {}, type: 'Error', status: status, error: errors }, status: status
    end
  end
  