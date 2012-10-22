class PdfsController < ApplicationController
  
  def fill
    @pdf = Pdf.find_by_url(params[:pdf])
    if @pdf
      pdf_file = @pdf.fill_in(params[:profile])
      send_file pdf_file.path, :type => "application/pdf"
    end
  end  
end
