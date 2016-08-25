#!/usr/bin/env python

# The Agent calls the appropriate methods on the Handler as requests are read off STDIN.
#
# Throwing an exception will cause the Agent to stop and an ErrorResponse to be sent.
# Some *Response objects (like SnapshotResponse) allow for returning their own error within the object itself.
# These types of errors will not stop the Agent and Kapacitor will deal with them appropriately.
#
# The Handler is called from a single thread, meaning methods will not be called concurrently.
#
# To write Points/Batches back to the Agent/Kapacitor use the Agent.write_response method, which is thread safe.

# This is a Usless template built from InfluxDB documentation example
# Take field data and do nothing with it
# Use this base when building a new UDF function

# Add to /etc/kapacitor/kapacitor.conf
# Under [udf.functions] 
#    [udf.functions.useless]
#       prog = "/usr/bin/python2"
#       args = ["-u", "/vagrant/udf_scripts/useless.py"]
#       timeout = "10s"
#       [udf.functions.useless.env]
#           PYTHONPATH = "/opt/kapacitor/udf/agent/py/"

import sys
#import json
from kapacitor.udf.agent import Agent, Handler
from kapacitor.udf import udf_pb2

import logging
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s %(levelname)s:%(name)s: %(message)s')
logger = logging.getLogger()

class UselessHandler(object):

    def __init__(self, agent):
        self._agent = agent

        self._field = None
        # State is for snapshot/restore
        # Currently we do nothing with it
        self._state = {}

    def info(self):
        response = udf_pb2.Response()
        # Batch input
        #response.info.wants = udf_pb2.BATCH
        # Stream input
        response.info.wants = udf_pb2.STREAM
        response.info.provides = udf_pb2.STREAM

        response.info.options['field'].valueTypes.append(udf_pb2.STRING)

        return response

    def init(self, init_req):
        success = True
        msg = ''

        for opt in init_req.options:
            if opt.name == 'field':
                self._field = opt.values[0].stringValue

        if self._field == 0:
            success = False
            msg += ' must supply a field name'

        response = udf_pb2.Response()
        response.init.success = success
        response.init.error = msg[1:]

        return response

    def snapshot(self):
        raise Exception("not supported")

    def restore(self, restore_req):
        raise Exception("not supported")

    def begin_batch(self):
        # Here we initialize our processor method with data point from beginning of batch/window
        raise Exception("not supported")

    def point(self, point):
        # This is where kapacitor actually processes the current data point
        # Invoke calculation logic (ideally from a separate class/module) here
        response = udf_pb2.Response()
        response.point.CopyFrom(point)

        self._agent.write_response(response)

    def end_batch(self, end_req):
        # Here we terminate batch processing
        raise Exception("not supported")

if __name__ == '__main__':
    a = Agent()
    h = UselessHandler(a)
    a.handler = h

    logger.info("Starting Useless Agent")
    a.start()
    a.wait()
    logger.info("Useless Agent finished")
