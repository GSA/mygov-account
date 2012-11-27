DEFAULT_FROM_EMAIL = "\"Team MyGov\" <projectmygov@gsa.gov>"
if Rails.env == "production"
  MYGOV_FORMS_HOME = "https://forms.usa.gov"
else
  MYGOV_FORMS_HOME = "http://localhost:3002"
end