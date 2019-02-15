import os

# The top path to /src, for changing directories
SRC_PATH = os.path.dirname(os.path.abspath(__file__))

# Traverses to subdirectories: each argument = 1 level down
ML_PATH = os.path.join(SRC_PATH, 'mappening', 'ml')
API_UTILS_PATH = os.path.join(SRC_PATH, 'mappening', 'api', 'utils')

# Updated coordinates of Bruin Bear
# Used as the default location
CENTER_LATITUDE = '34.070966'
CENTER_LONGITUDE = '-118.445'

# The time period before now, in days
# For finding and updating events instead of removing them 
BASE_EVENT_START_BOUND = 0
