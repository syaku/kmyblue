# frozen_string_literal: true

class Api::V1::AntennasController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:lists' }, only: [:index, :show]
  before_action -> { doorkeeper_authorize! :write, :'write:lists' }, except: [:index, :show]

  before_action :require_user!
  before_action :set_antenna, except: [:index]

  rescue_from ArgumentError do |e|
    render json: { error: e.to_s }, status: 422
  end

  def index
    @antennas = Antenna.where(account: current_account).all
    render json: @antennas, each_serializer: REST::AntennaSerializer
  end

  def show
    render json: @antenna, serializer: REST::AntennaSerializer
  end

  private

  def set_antenna
    @antenna = Antenna.where(account: current_account).find(params[:id])
  end
end
