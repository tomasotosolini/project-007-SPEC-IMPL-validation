class DomusController < ApplicationController
  def index
    @configured_domus = XlSimulator.configured_list
    @running_domus    = XlSimulator.running_list
  end
end
