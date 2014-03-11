require 'spec_helper'
require 'open3'

RSpec::Matchers.define :have_valid_html do |expected|

  # warnings that are blacklisted and hence ignored.
  BLACKLISTED_ERRORS = ['<meta> proprietary attribute "property"', '<head> proprietary attribute "prefix"']

  match do |html|
    validate_html(html)
  end

  failure_message_for_should do |actual|
    "expected valid html but there were errors found:\n #{puts @errors}"
  end

  failure_message_for_should_not do |actual|
    "expected invalid html but it was valid"
  end

  description do
    "have valid html"
  end

end

#
# helper methods for custom matcher
#

# this can probably be avoided by piping stdin straight to tidy but for now this will suffice
def create_temp_file(html)
  file = Tempfile.new('rspec_html_validation')
  file.write(html)
  file.close
  file
end

# validate html against tidy and capture errors in instance var
def validate_html(html)
  file = create_temp_file(html)

  stdin, stdout, stderr, wait_thr = Open3.popen3('tidy', '-e', file.path)
  parse_errors(stderr.gets(nil).split("\n\n\nAbout this fork of Tidy").first)

  return nil unless @errors.empty?
  
  ensure
    file.close
    file.unlink
end

def parse_errors(errors)
  # grab notes
  @notes = errors.split("\n\n\n").last
  
  # atomize errors
  errors = errors.split("\n")
  
  # grab summary
  @summary = errors.select { |e| e.include?('errors were found!') }.first

  # grab errors
  @errors = errors.select { |e| e.match(/line \d/) }

  # remove blacklisted errors

end
