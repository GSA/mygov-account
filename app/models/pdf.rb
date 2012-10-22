require 'open-uri'
require 'pdf_forms'

class Pdf < ActiveRecord::Base  
  belongs_to :form
  has_many :pdf_fields
  before_validation :generate_slug
  validates_presence_of :name, :slug, :url
  validates_uniqueness_of :slug, :url
  attr_accessible :name, :slug, :url, :x_offset, :y_offset, :form_id, :is_fillable, :page_number
  
  def fill_in(profile_data)
    template_pdf_file = open(self.url)    
    filled_in_pdf_file = Tempfile.new( ['pdf', '.pdf'] )
    if self.is_fillable?
      pdftk = PdfForms.new(PDFTK_PATH)
      pdftk.fill_form template_pdf_file.path, filled_in_pdf_file.path, map_profile_data_to_fillable_fields(profile_data)
    else
      Prawn::Document.generate filled_in_pdf_file.path, :template => template_pdf_file.path do |pdf|
        pdf.font("Helvetica", :size=> 10)
        map_profile_data_to_non_fillable_fields(profile_data).each do |field|
          pdf.go_to_page field[:page]
          pdf.draw_text field[:text], :at => field[:at]
        end
      end
    end
    filled_in_pdf_file
  end
  
  private
  
  def generate_slug
  	self.slug = self.name.parameterize if self.name
  end

  def map_profile_data_to_fillable_fields(profile_data)
    data = {}
    self.pdf_fields.each do |pdf_field|
      unless pdf_field.profile_field_name.nil? and profile_data[pdf_field.profile_field_name].present?
        data.merge!(pdf_field.name.to_sym => profile_data[pdf_field.profile_field_name])
      end
    end
    data
  end
  
  def map_profile_data_to_non_fillable_fields(profile_data)
    data = []
    self.pdf_fields.each do |pdf_field|
      unless pdf_field.profile_field_name.nil? and profile_data[pdf_field.profile_field_name].present?
        data << {:text => profile_data[pdf_field.profile_field_name], :at => [self.x_offset + pdf_field.x, self.y_offset + pdf_field.y], :page => pdf_field.page_number}
      end
    end
    data
  end
end