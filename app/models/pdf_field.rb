class PdfField < ActiveRecord::Base
  belongs_to :pdf
  attr_accessible :name, :x, :y, :pdf_id, :profile_field_name, :page_number
  validates_presence_of :name, :page_number
end
