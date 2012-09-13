class PdfsController < ApplicationController
  
  def show
    @pdf = Pdf.find_by_slug(params[:id])
    respond_to do |format|
      format.pdf {
        pdf_file = @pdf.fill_in(params[:profile])
        send_file pdf_file.path, :type => "application/pdf" 
      }
    end
  end
end
