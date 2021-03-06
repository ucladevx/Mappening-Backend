from mappening.utils.secrets import FACEBOOK_APP_ID, FACEBOOK_APP_SECRET

from flask_oauth import OAuth

# OAuth for authentication. Also supports Google Authentication.
oauth = OAuth()
facebook_oauth = oauth.remote_app('facebook',
    base_url='https://graph.facebook.com/',
    request_token_url=None,
    access_token_url='/oauth/access_token',
    authorize_url='https://www.facebook.com/dialog/oauth',
    consumer_key=FACEBOOK_APP_ID,
    consumer_secret=FACEBOOK_APP_SECRET,
    request_token_params={'scope': 'email'}
)
