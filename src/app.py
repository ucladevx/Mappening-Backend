from mappening import app
from mappening.utils import scheduler
from mappening.api.utils import event_utils

from flask import Flask

from threading import Thread

@app.route('/')
def index():
    return "Mappening is running!"

if __name__ == "__main__":
    # Another thread to run the periodic events update, daily
    event_update_thread = Thread(target = scheduler.event_thread_func)
    event_update_thread.start()

    code_update_date = "4/2/18"
    print("Updated on: {0}".format(code_update_date))

    print("Mappening is happening!\n")

    print('UPDATE EVENTS?? Not yet\n')
    # need to pass in args from command line
    # event_utils.update_ucla_events_database()

    # Flask defaults to port 5000
    # If debug is true, runs 2 instances at once (so two copies of all threads)
    app.run(host='0.0.0.0', debug=False)

    

