# encoding: utf-8

require 'nonomura'

class TranslationsController < ApplicationController
  def new
  end

  def create
    @text = Nonomura.translate(params[:text], params[:level] || 4)

    respond_to do |format|
      format.js
      format.json{ render :json => {text: @text} }
    end
  end
end
