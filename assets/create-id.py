#!/usr/bin/env python3
"""
Generate unique IDs:

- Avoids easily mistaken letters&numbers
  (See http://www.ncbi.nlm.nih.gov/pmc/articles/PMC3541865/)
- Base64-URL encoded random UUID
- Only picks IDs that could be used as a variable name
- Always have at least 1 of each: a-z, A-Z, 0-9
"""

import uuid
import base64
import re


def create_id():
    result = '1'
    while re.match('.*[Il1oO0B87Z2_-]', result) or not re.match('[a-z]', result) \
            or not re.match('.*[A-Z]', result) or not re.match('.*[0-9]', result):
        result = base64.b64encode(uuid.uuid4().bytes, b'-_').decode()
    return result.rstrip('=\\n')

if __name__ == "__main__":
    print(create_id(), end='')
