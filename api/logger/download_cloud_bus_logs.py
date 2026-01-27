import argparse
import json
import re
from datetime import datetime, timedelta
from pathlib import Path
from typing import Optional, Iterable

import boto3
from botocore.exceptions import ClientError


class S3BusLogDownloader:
    """
    Lists S3 objects under prefix whose key contains /date=YYYY-MM-DD/
    and date <= cutoff_date (inclusive).

    Behavior controlled by flags:
      - download (default True): download files locally
      - delete   (default True): delete from S3 (only after successful download if download=True)
    """

    DATE_RE = re.compile(r"/date=(\d{4}-\d{2}-\d{2})/")

    def __init__(self, config: dict):
        self.bucket: str = config["bucket"]
        self.prefix: str = config.get("prefix", "")
        self.output_dir: Path = Path(config.get("output_dir", "downloads"))
        self.region: Optional[str] = config.get("region")

        self.output_dir.mkdir(parents=True, exist_ok=True)

        session = boto3.Session()
        self.s3 = (
            session.client("s3", region_name=self.region)
            if self.region
            else session.client("s3")
        )

    @classmethod
    def extract_date_from_key(cls, key: str) -> Optional[str]:
        m = cls.DATE_RE.search(key)
        return m.group(1) if m else None

    def iter_keys(self) -> Iterable[str]:
        paginator = self.s3.get_paginator("list_objects_v2")
        for page in paginator.paginate(Bucket=self.bucket, Prefix=self.prefix):
            for obj in page.get("Contents", []):
                yield obj["Key"]

    def run(self, cutoff_date: str, download: bool = True, delete: bool = True) -> dict:
        matched = 0
        downloaded = 0
        deleted = 0
        errors = 0

        for key in self.iter_keys():
            key_date = self.extract_date_from_key(key)
            if not key_date:
                continue

            if key_date <= cutoff_date:
                matched += 1
                s3_url = f"s3://{self.bucket}/{key}"

                # If not downloading, we can still optionally delete
                if not download:
                    print(f"[MATCH] {s3_url}")
                    if delete:
                        try:
                            self.s3.delete_object(Bucket=self.bucket, Key=key)
                            deleted += 1
                            print(f"[DELETED] {s3_url}")
                        except ClientError as e:
                            errors += 1
                            print(f"[ERROR deleting] {s3_url}: {e}")
                    continue

                # Download path preserves key structure
                local_path = self.output_dir / key
                local_path.parent.mkdir(parents=True, exist_ok=True)

                try:
                    self.s3.download_file(self.bucket, key, str(local_path))
                    downloaded += 1
                    print(f"[DOWNLOADED] {s3_url} -> {local_path}")

                    # Only delete after successful download (when download=True)
                    if delete:
                        self.s3.delete_object(Bucket=self.bucket, Key=key)
                        deleted += 1
                        print(f"[DELETED] {s3_url}")

                except ClientError as e:
                    errors += 1
                    print(f"[ERROR] {s3_url}: {e}")

        return {
            "cutoff_date": cutoff_date,
            "download": download,
            "delete": delete,
            "matched_objects": matched,
            "downloaded_objects": downloaded,
            "deleted_objects": deleted,
            "errors": errors,
            "output_directory": str(self.output_dir.resolve()),
        }


def load_config(path: Path) -> dict:
    with open(path, "r") as f:
        return json.load(f)


def default_cutoff_date_local_yesterday() -> str:
    # yesterday in your computer's local timezone
    yesterday = datetime.now().astimezone().date() - timedelta(days=1)
    return yesterday.isoformat()


def main():
    parser = argparse.ArgumentParser(
        description="Download S3 bus logs up to a cutoff date; optionally delete from S3."
    )

    parser.add_argument(
        "--cutoff_date",
        default=None,
        help="Cutoff date YYYY-MM-DD (inclusive). Defaults to yesterday (local date).",
    )

    # These default True, but you can turn them off with --no-download / --no-delete
    parser.add_argument(
        "--download",
        default=True,
        action=argparse.BooleanOptionalAction,
        help="Download matching objects locally (default: True). Use --no-download to disable.",
    )
    parser.add_argument(
        "--delete",
        default=True,
        action=argparse.BooleanOptionalAction,
        help="Delete matching objects from S3 (default: True). Use --no-delete to disable.",
    )

    parser.add_argument(
        "--config",
        default="download_config.json",
        help="Path to JSON config file (default: download_config.json).",
    )

    args = parser.parse_args()

    cutoff = args.cutoff_date or default_cutoff_date_local_yesterday()
    config = load_config(Path(args.config))

    downloader = S3BusLogDownloader(config)
    summary = downloader.run(cutoff_date=cutoff, download=args.download, delete=args.delete)

    print("\nSummary")
    print("-------")
    print(f"Cutoff date:        {summary['cutoff_date']}")
    print(f"Download:           {summary['download']}")
    print(f"Delete:             {summary['delete']}")
    print(f"Matched objects:    {summary['matched_objects']}")
    print(f"Downloaded objects: {summary['downloaded_objects']}")
    print(f"Deleted objects:    {summary['deleted_objects']}")
    print(f"Errors:             {summary['errors']}")
    print(f"Output directory:   {summary['output_directory']}")


if __name__ == "__main__":
    main()
