class ParksController < ApplicationController
  before_action :set_parking, only: [:pay, :out]

  # GET /parking
  def index
    @parking = Park.all
    json_response(@parking)
  end

  # POST /parking
  def create
    @parking = Park.create!(parking_params)
    json_response(@parking, :created)
  end

  # GET /parking/:id
  def show
    parking = Park.find_by!(plate: params[:plate])
    json_response(parking.getInfo())
  end

  # PUT /parking/:id/pay
  def pay
    @parking.pay()
    head :no_content
  end

  # PUT /parking/:id/out
  def out
    @parking.out()
    head :no_content
  end

  def parking_params
    params.permit(:plate)
  end

  def set_parking
    @parking = Park.find(params[:id])
  end
end