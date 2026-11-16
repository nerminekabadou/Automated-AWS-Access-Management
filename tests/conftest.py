import os
import sys

os.environ.setdefault("AWS_DEFAULT_REGION", "us-east-2")
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "lambda_code"))
