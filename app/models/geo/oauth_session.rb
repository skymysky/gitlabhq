class Geo::OauthSession
  include ActiveModel::Model
  include HTTParty

  attr_accessor :state
  attr_accessor :return_to

  API_PREFIX = '/api/v3/'

  def is_oauth_state_valid?
    return true unless state
    salt, hmac, return_to = state.split(':', 3)

    return false unless return_to
    hmac == generate_oauth_hmac(salt, return_to)
  end

  def generate_oauth_state
    return unless return_to
    hmac = generate_oauth_hmac(oauth_salt, return_to)
    "#{oauth_salt}:#{hmac}:#{return_to}"
  end

  def get_oauth_state_return_to
    state.split(':', 3)[2] if state
  end

  def authenticate(access_token)
    opts = {
      query: access_token
    }
    response = self.class.get(authenticate_endpoint, default_opts.merge(opts))

    build_response(response)
  end

  def authorize_url(params = {})
    oauth_client.auth_code.authorize_url(params)
  end

  def get_token(code, params = {}, opts = {})
    oauth_client.auth_code.get_token(code, params, opts).token
  end

  private

  def generate_oauth_hmac(salt, return_to)
    return false unless return_to
    digest = OpenSSL::Digest.new('sha256')
    key = Gitlab::Application.secrets.secret_key_base + salt
    OpenSSL::HMAC.hexdigest(digest, key, return_to)
  end

  def oauth_salt
    @salt ||= SecureRandom.hex(16)
  end

  def oauth_client
    @client ||= begin
      ::OAuth2::Client.new(
        oauth_app.uid,
        oauth_app.secret,
        {
          site: primary_node_url,
          authorize_url: 'oauth/authorize',
          token_url: 'oauth/token'
        }
      )
    end
  end

  def oauth_app
    Gitlab::Geo.oauth_authentication
  end

  def authenticate_endpoint
    File.join(primary_node_url, API_PREFIX, 'user')
  end

  def primary_node_url
    Gitlab::Geo.primary_node.url
  end

  def default_opts
    {
      headers: { 'Content-Type' => 'application/json' },
    }
  end

  def build_response(response)
    case response.code
    when 200
      response.parsed_response
    when 401
      raise UnauthorizedError
    else
      nil
    end
  end
end
