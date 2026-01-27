import os
import time
import boto3
from datetime import datetime, timezone

from bus_logger import BusLogger

class CloudBusLogger(BusLogger):
    def __init__(self):
        super().__init__()
        self.s3 = boto3.client("s3")
        self.bucket = os.environ["BUCKET"]
        self.prefix = os.environ.get("PREFIX", "bus-logs")
        self.runs_per_invoke = int(os.environ.get("RUNS_PER_INVOKE", "2"))
        self.sleep_seconds = int(os.environ.get("SLEEP_SECONDS", "30"))

    def _s3_key_for(self, ts: datetime) -> str:
        date = ts.strftime("%Y-%m-%d")
        hour = ts.strftime("%H")
        stamp = ts.isoformat().replace(":", "-")
        return f"{self.prefix}/date={date}/hour={hour}/{stamp}.txt"

    def _write_snapshot_to_s3(self, text: str, ts: datetime) -> str:
        key = self._s3_key_for(ts)
        self.s3.put_object(
            Bucket=self.bucket,
            Key=key,
            Body=text.encode("utf-8"),
            ContentType="text/plain; charset=utf-8",
        )
        return key

    def run_logging_cycle(self):
        keys = []
        for i in range(self.runs_per_invoke):
            ts = datetime.now(self.timezone)
            text = self.log()
            keys.append(self._write_snapshot_to_s3(text, ts))
            if i < self.runs_per_invoke - 1:
                time.sleep(self.sleep_seconds)

        return {"status": "ok", "objects_written": len(keys), "keys": keys}

def lambda_handler(event, context):
    cloud_logger = CloudBusLogger()
    return cloud_logger.run_logging_cycle()
