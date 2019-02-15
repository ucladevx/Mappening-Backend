from mappening.api.utils import event_utils
from mappening.utils.database import events_log_collection

import schedule
import time, datetime, pytz
from dateutil.tz import tzlocal
from threading import Thread

# "return a StringIO-like stream for reading and writing"
# Basically allows stdoutput to be saved into a stream
from cStringIO import StringIO
import sys, traceback

# (hour, minute) pairs for when to refresh events every day 
# Using 24 hour clock, in LA time
# 5:00 AM, 1:10 PM, 5:10 PM
update_time_tuples = [(5, 0), (13, 10), (19, 10)]
event_refresh_tag = 'event-refresh'

# Log output of update event call in DB!
# Store stdout into string, then save and print it out
def get_new_events_with_logs():
    print('\n\n\n\n\n\n\n\n######\n\n######\n\n######\n\n')
    print('BEGIN POPULATING EVENTS DATABASE')
    print('\n\n######\n\n######\n\n######\n\n\n\n\n\n\n')

    log_dict = {}

    orig_stdout = sys.stdout
    saved_output = StringIO()
    sys.stdout = saved_output

    try:
        event_utils.update_ucla_events_database()
    except KeyboardInterrupt:
        print('Received KeyboardInterrupt.')
    except SystemExit:
        print('Requested to exit system.')
    except:
        print(traceback.format_exc())
        log_dict['ERROR'] = True

    sys.stdout = orig_stdout
    saved_output_str = saved_output.getvalue()
    
    # Save into mLab
    log_timestr = pytz.timezone('America/Los_Angeles') \
                    .localize(datetime.datetime.now()) \
                    .strftime('%Y-%m-%d %H:%M:%S')
    log_dict[log_timestr] = saved_output_str
    events_log_collection.insert_one(log_dict)
    
    # Print out into terminal anyway
    print(saved_output_str)

def update_for_today():
    # Remove current refresh and replace with new ones
    # Handles case of daylight savings
    schedule.clear(event_refresh_tag)
    today = pytz.timezone('America/Los_Angeles').localize(datetime.datetime.now())

    for (hour, minute) in update_time_tuples:
        today = today.replace(hour=hour, minute=minute)
        adjusted_time = today.astimezone(pytz.UTC).strftime('%H:%M')
        # Call update_u_e_d with no arguments, so defaults used
        schedule.every().day.at(adjusted_time).do(get_new_events_with_logs).tag(event_refresh_tag)
        print('Refresh at {0}, in UTC'.format(adjusted_time))
    print('Schedule {0} times on {1}'.format(len(update_time_tuples), str(today.date())))

def event_thread_func():
    update_for_today()
    # Need to reschedule every day, so that time zone changes (like DST) take effect
    schedule.every().day.at('00:00').do(update_for_today).tag('daily-refresh')

    while True:
        schedule.run_pending()
        # Kind of like a check every interval of time, if any jobs should run
        time.sleep(30)
