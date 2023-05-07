import os

from google.cloud import storage
from flask import jsonify

import google.auth
import google.auth.transport.requests
import google.oauth2.id_token
import requests

CLOUD_RUN_URL = os.environ.get('CLOUD_RUN_URL')
TEMP_BUCKET_NAME = os.environ.get('TEMP_STORAGE_BUCKET')

def synthesis_audio(headers, audio_query, speaker_id):
    query_params = {
        'enable_interrogative_upspeak': True,
        'speaker': speaker_id
    }

    return requests.post(f"{CLOUD_RUN_URL}/synthesis", json=audio_query, headers=headers, params=query_params).content

def upload_gcs(step, workflow_id, audio_data):
    # Cloud Storageにアップロード
    storage_client = storage.Client()

    bucket = storage_client.bucket(TEMP_BUCKET_NAME)
    blob = bucket.blob(f"{workflow_id}/{str(step)}_{workflow_id}.wav")
    blob.upload_from_string(audio_data, content_type='audio/wav')


def main(request):
    request_json = request.get_json(silent=True)

    speaker_id = request_json.get('speaker_id')
    workflow_id = request_json.get('workflow_id')
    step = request_json.get('step')
    audio_query = request_json.get('audio_query')
    
    if speaker_id is None:
        return jsonify({'message': 'speaker_id is missing'}), 400
    if workflow_id is None:
        return jsonify({'message': 'workflow_id is missing'}), 400
    if step is None:
        return jsonify({'message': 'step is missing'}), 400
    if audio_query is None:
        return jsonify({'message': 'audio_query is missing'}), 400
    
    auth_req = google.auth.transport.requests.Request()
    id_token = google.oauth2.id_token.fetch_id_token(auth_req, CLOUD_RUN_URL)
    
    headers = {'Authorization': f"Bearer {id_token}"}

    audio_data = synthesis_audio(headers, audio_query, speaker_id)

    upload_gcs(step, workflow_id, audio_data)

    return jsonify({'message': 'ok'}), 200
