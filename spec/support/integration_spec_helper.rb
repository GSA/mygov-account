module IntegrationSpecHelper
  def login_with_oauth(service = :google)
    visit "/auth/#{service}"
  end
end