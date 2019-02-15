# Run this before anything else: checks for command line arguments
# Default: no arguments, like when using Makefile (normal API backend running)
import argparse
parser = argparse.ArgumentParser()
parser.add_argument('-t', '--test', 
    help='Use a test database, to protect live data.', action='store_true')
parser.add_argument('-d', '--days-before', 
    help='Specify # of days to go back in time for past events.', type=int)
parser.add_argument('-c', '--clear', 
    help='Clear out old database data to start anew.', action='store_true')
parser.add_argument('-p', '--prod', 
    help='Run production version of Mappening backend', action='store_true')
args = parser.parse_args()

# There's an 'app' Flask object in mappening's __init__.py
# App object also links to blueprints to other modules
from mappening import app
from mappening.utils import scheduler
from mappening.api.utils import event_utils

from flask import Flask
import datetime
from threading import Thread

# Used to check that server is running, visit http://api.mappening.io:5000/
@app.route('/')
def index():
    return "Mappening API is running!"

# Runs threads to periodically update events. Also updates database. 
# For dev purposes, only call this when we are in prod.
def thread_scheduler(args):
    # Another thread to run the periodic events update, daily
    event_update_thread = Thread(target = scheduler.event_thread_func)
    event_update_thread.start()

    print("UPDATING EVENTS FIRST...\n")
    dbit = args.days_before

    # Pass in args from commandline
    if not dbit or dbit < 1:
        dbit = 0
    event_utils.update_ucla_events_database(use_test=args.test,
                                            days_back_in_time=dbit,
                                            clear_old_db=args.clear)

# Flask defaults to port 5000
# If debug is true, runs 2 instances at once (so two copies of all threads)
if __name__ == "__main__":
    print('Arguments passed: {0}'.format(args))
    if not args.prod:
        # Saved changes to Python files are registered and app automatically 
        # reloads. Does not update events database.
        print("\n~~~~~~~~~~~~~~~~~~~\n~~~ IN DEV MODE ~~~\n~~~~~~~~~~~~~~~~~~~\n")
        app.run(host='0.0.0.0', debug=True)
    else:
        thread_scheduler(args)
        app.run(host='0.0.0.0', debug=False)
