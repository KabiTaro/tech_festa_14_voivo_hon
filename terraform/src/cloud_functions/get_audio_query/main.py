import os

import google.auth
import google.auth.transport.requests
import google.oauth2.id_token
import requests

from flask import jsonify

CLOUD_RUN_URL = os.environ.get('CLOUD_RUN_URL')

def get_audio_query(headers, speaker_id, query_text):
    query_params = {
        'speaker': speaker_id,
        'text': query_text
    }

    return requests.post(f"{CLOUD_RUN_URL}/audio_query", headers=headers, params=query_params).json()

def main(request):
    request_json = request.get_json(silent=True)

    speaker_id = request_json.get('speaker_id')
    query_text = request_json.get('query_text')

    if speaker_id is None:
        return jsonify({'message': 'speaker_id is missing'}), 400
    if query_text is None:
        return jsonify({'message': 'query_text is missing'}), 400

    auth_req = google.auth.transport.requests.Request()
    id_token = google.oauth2.id_token.fetch_id_token(auth_req, CLOUD_RUN_URL)

    headers = {
        'Authorization': f"Bearer {id_token}"
    }

    audio_query = get_audio_query(headers, speaker_id, query_text)

    return jsonify(audio_query),200
