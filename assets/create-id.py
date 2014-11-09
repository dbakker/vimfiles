#!/usr/bin/env python3
"""
Generate unique IDs:

  - Avoids easily mistaken letters&numbers
    (See http://www.ncbi.nlm.nih.gov/pmc/articles/PMC3541865/)
  - Base64-URL encoded random UUID
  - Only picks IDs that could be used as a variable name
"""

import uuid
import base64
import re

result = '1'
while re.match('.*[Il1oO0B87Z2_-]', result) or re.match('^[0-9_-]', result):
    result = base64.b64encode(uuid.uuid4().bytes, b'-_').decode()

print(result.rstrip('=\\n'))
