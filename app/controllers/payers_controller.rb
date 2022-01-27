class PayersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_payers, only: [:show, :edit, :update, :destroy]


  def index
    respond_to do |format|
      format.html
      format.json { render json: PayerDatatable.new(params) }
    end
  end

  def show
  end

  def new
    @payer = Payer.new
  end

  def edit
  end

  def create
    @payer = Payer.new(payers_params)
    respond_to do |format|
      if @payer.save
        format.html { redirect_to payers_url, notice: 'Payer was successfully created.' }
        format.json { render :show, status: :created, location: @payer }
      else
        format.html { render :new }
        format.json { render json: @payer.errors, status: :unprocessable_entity }
      end
    end
  end


  def update
    respond_to do |format|
      if @payer.update(payers_params)
        format.html { redirect_to payers_url, notice: 'Payer was successfully updated.' }
        format.json { render :show, status: :ok, location: @payer }
      else
        format.html { render :edit }
        format.json { render json: @payer.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @payer.destroy
    respond_to do |format|
      format.html { redirect_to payers_url, notice: 'Payer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  private

  def set_payers
    @payer = Payer.find(params[:id])
  end

  def payers_params
    params.require(:payer).permit(:payer_id, :payer_name)
  end
end






