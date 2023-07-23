import cgi

event = {
    "resource": "/audioToTextService",
    "path": "/audioToTextService",
    "httpMethod": "GET",
    "headers": {
        "Accept": "*/*",
        "accept-encoding": "gzip, deflate, br",
        "content-type": "multipart/form-data; boundary=--------------------------298238657967180241132054",
        "Host": "t4sqopo2i5.execute-api.eu-north-1.amazonaws.com",
        "User-Agent": "Thunder Client (https://www.thunderclient.com)",
        "X-Amzn-Trace-Id": "Root=1-64b784cb-600c89b44fe0416252b5e045",
        "X-Forwarded-For": "103.85.8.185",
        "X-Forwarded-Port": "443",
        "X-Forwarded-Proto": "https",
    },
    "multiValueHeaders": {
        "Accept": ["*/*"],
        "accept-encoding": ["gzip, deflate, br"],
        "content-type": [
            "multipart/form-data; boundary=--------------------------298238657967180241132054"
        ],
        "Host": ["t4sqopo2i5.execute-api.eu-north-1.amazonaws.com"],
        "User-Agent": ["Thunder Client (https://www.thunderclient.com)"],
        "X-Amzn-Trace-Id": ["Root=1-64b784cb-600c89b44fe0416252b5e045"],
        "X-Forwarded-For": ["103.85.8.185"],
        "X-Forwarded-Port": ["443"],
        "X-Forwarded-Proto": ["https"],
    },
    "queryStringParameters": None,
    "multiValueQueryStringParameters": None,
    "pathParameters": None,
    "stageVariables": None,
    "requestContext": {
        "resourceId": "3kmssy",
        "resourcePath": "/audioToTextService",
        "httpMethod": "GET",
        "extendedRequestId": "ITGv2FSgAi0Fwng=",
        "requestTime": "19/Jul/2023:06:38:03 +0000",
        "path": "/default/audioToTextService",
        "accountId": "692605435704",
        "protocol": "HTTP/1.1",
        "stage": "default",
        "domainPrefix": "t4sqopo2i5",
        "requestTimeEpoch": 1689748683528,
        "requestId": "c8459018-4d22-47ea-b154-ea014fc9fb4c",
        "identity": {
            "cognitoIdentityPoolId": None,
            "accountId": None,
            "cognitoIdentityId": None,
            "caller": None,
            "sourceIp": "103.85.8.185",
            "principalOrgId": None,
            "accessKey": None,
            "cognitoAuthenticationType": None,
            "cognitoAuthenticationProvider": None,
            "userArn": None,
            "userAgent": "Thunder Client (https://www.thunderclient.com)",
            "user": None,
        },
        "domainName": "t4sqopo2i5.execute-api.eu-north-1.amazonaws.com",
        "apiId": "t4sqopo2i5",
    },
    "body": "LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLTI5ODIzODY1Nzk2NzE4MDI0MTEzMjA1NA0KQ29udGVudC1EaXNwb3NpdGlvbjogZm9ybS1kYXRhOyBuYW1lPSJtc2ciDQoNCmhlbGxvDQotLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tMjk4MjM4NjU3OTY3MTgwMjQxMTMyMDU0LS0NCg==",
    "isBase64Encoded": True,
}

import requests

reqUrl = (
    "https://t4sqopo2i5.execute-api.eu-north-1.amazonaws.com/default/audioToTextService"
)

post_files = {
    "music": open(r"d:\projects\recorder\backend\Recording.wav", "rb"),
}
headersList = {
    "Accept": "*/*",
    "User-Agent": "Thunder Client (https://www.thunderclient.com)",
}

payload = ""

response = requests.request(
    "GET", reqUrl, data=payload, files=post_files, headers=headersList
)

# print(response.text)

from io import BytesIO
import base64
from requests_toolbelt.multipart import decoder

c_type, c_data = cgi.parse_header(event["headers"]["content-type"])
content_type = event["headers"]["content-type"]
body = base64.b64decode(response.text)
# fd = cgi.parse_multipart(body, c_data)
multipart_data = decoder.MultipartDecoder(body, content_type)
# print(multipart_data.parts[0].content)
f = open("text.wav", "wb")
f.write(multipart_data.parts[0].content)
f.close()
