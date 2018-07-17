#!/usr/bin/env python2.7
from __future__ import print_function

import sys
import time
from threading import Thread
from subprocess import check_call, CalledProcessError

from pymesos import MesosExecutorDriver, Executor, decode_data
from addict import Dict


class HTcondorDriver(MesosExecutorDriver):
    def reserve_storage(self):
        body = dict(
            type='MESSAGE',
            executor_id=self.executor_id,
            framework_id=self.framework_id,
            message=dict(
                data=[],
            ),
        )
        self._send(body)


class HTCondorExcutor(Executor):
    def launchTask(self, driver, task):
        def run_task(task):
            update = Dict()
            update.task_id.value = task.task_id.value
            update.state = 'TASK_RUNNING'
            update.timestamp = time.time()
            driver.sendStatusUpdate(update)

            # /usr/local/bin/dodas.sh
            try:
                startd = check_call("/usr/local/bin/dodas.sh", shell=True)
                print(startd)
            except CalledProcessError:
                update = Dict()
                update.task_id.value = task.task_id.value
                update.state = 'TASK_FAILED'
                update.timestamp = time.time()
                driver.sendStatusUpdate(update)

            update = Dict()
            update.task_id.value = task.task_id.value
            update.state = 'TASK_FINISHED'
            update.timestamp = time.time()
            driver.sendStatusUpdate(update)

        thread = Thread(target=run_task, args=(task,))
        thread.start()


if __name__ == '__main__':
    import logging
    logging.basicConfig(level=logging.DEBUG)
    driver = HTcondorDriver(HTCondorExcutor(), use_addict=True, timeout=1)
    driver.run()
