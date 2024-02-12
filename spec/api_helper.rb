def authorize_insee_token
  ENV['INSEE_CONSUMER_KEY'] = 'consumer_key'
  ENV['INSEE_CONSUMER_TOKEN'] = 'consumer_token'
  insee_token = Base64.strict_encode64("consumer_key:consumer_token")
  stub_request(:post, 'https://api.insee.fr/token')
    .with(headers: { 'Authorization' => "Basic #{insee_token}" }, body: { grant_type: 'client_credentials' })
    .to_return(
      body: "{ 'token1234' }".to_json
    )
end

def authorize_rne_token
  ENV['RNE_USERNAME'] = 'rene nereux'
  ENV['RNE_PASSWORD'] = 'p4ssw0rd'
  stub_request(:post, 'https://registre-national-entreprises.inpi.fr/api/sso/login')
    .with(body: { username: 'rene nereux', password: 'p4ssw0rd' })
    .to_return(
      body: "{ 'token1234' }".to_json
    )
end

def stub_mjml_google_fonts
  stub_request(:get, 'https://fonts.googleapis.com/css?family=Ubuntu:300,400,500,700')
    .to_return(
      body: "".to_json
    )
end

def authorize_france_competence_token
  ENV['FRANCE_COMPETENCE_LOGIN'] = 'fc_login'
  ENV['FRANCE_COMPETENCE_PASSWORD'] = 'fc_password'
  ENV['FRANCE_COMPETENCE_AUTH_KEY'] = 'fc_auth_key'
  stub_request(:post, 'https://api-preprod.francecompetences.fr/siropartfc-auth/login')
    .with(
      body: { login: 'fc_login', password: 'fc_password' },
      headers: { 'X-Gravitee-Api-Key' => 'fc_auth_key' }
    )
    .to_return(
      body: "token1234"
    )
end

def stub_france_competence_siret(url, body)
  ENV['FRANCE_COMPETENCE_SIRO_KEY'] = 'fc_siro_key'
  stub_request(:get, url)
    .with(headers: {
      'X-Gravitee-Api-Key' => 'fc_siro_key',
      'Authorization' => 'Bearer token1234'
    })
    .to_return(body: body)
end
