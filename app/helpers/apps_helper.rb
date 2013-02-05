module AppsHelper
  
  def app_status(app)
    app.is_public ? "Public" : "Sandboxed"
  end
end