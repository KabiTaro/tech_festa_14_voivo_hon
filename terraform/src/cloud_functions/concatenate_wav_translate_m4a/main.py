import os
import base64
import re
import io

import requests
import google.auth
import google.auth.transport.requests
import google.oauth2.id_token

from flask import jsonify
from google.cloud import storage
from pydub import AudioSegment

CLOUD_RUN_URL = os.environ.get('CLOUD_RUN_URL')
TEMP_BUCKET_NAME = os.environ.get('TEMP_STORAGE_BUCKET')
UPLOAD_BUCKET_NAME = os.environ.get('UPLOAD_STORAGE_BUCKET')

# base64エンコードされた複数のwavデータを一つに結合する
def concatenate_base64_encoded_wav_files(headers, ar_base64_encoded_audio):
    return requests.post(f"{CLOUD_RUN_URL}/connect_waves", json=ar_base64_encoded_audio,headers=headers).content

def get_sequential_number(file_name):
    match = re.search(r"^(\d+)_.*.wav", os.path.basename(file_name))
    return int(match.group(1))

def wave_to_base64(bucket,ar_object_list):
    ar_base64_encoded_audio = []

    for file_name in ar_object_list:
        blob = bucket.blob(file_name)
        file_data = blob.download_as_string()
        # base64 エンコーディング
        encoded_data = base64.b64encode(file_data)

        # エンコードされたデータを文字列に変換して表示
        encoded_str = encoded_data.decode('utf-8')
        ar_base64_encoded_audio.append(encoded_str)
    return ar_base64_encoded_audio

def convert_wav_to_m4a(wav_data):
    audio = AudioSegment.from_file(io.BytesIO(wav_data), format='wav')
    m4a_audio = audio.export(format='mp4', codec='aac')

    # m4aのバイナリデータに変換
    m4a_data = m4a_audio.read()

    return m4a_data

def get_audio_duration_from_binary(binary_data):
    audio = AudioSegment.from_file(io.BytesIO(binary_data), format="wav")
    duration = len(audio)

    return duration

def get_object_list(bucket,workflow_id):
    # バケット内のオブジェクトを一覧表示
    objects = bucket.list_blobs(prefix=f"{workflow_id}/")
    listed_obj = [obj.name for obj in objects if re.search(r"^(\d+)_.*.wav", os.path.basename(obj.name))]

    return sorted(listed_obj, key=get_sequential_number)

def upload_audio_bynary(bucket,workflow_id,audio_binary):
    blob = bucket.blob(f"{workflow_id}/concatenate_{workflow_id}.m4a")
    blob.upload_from_string(audio_binary, content_type='audio/m4a')

    return blob.public_url

def main(request):
    request_json = request.get_json(silent=True)

    workflow_id = request_json.get('workflow_id')

    if workflow_id is None:
        return jsonify({'message': 'workflow_id is missing'}), 400

    auth_req = google.auth.transport.requests.Request()
    id_token = google.oauth2.id_token.fetch_id_token(auth_req, CLOUD_RUN_URL)

    headers = {
        'Authorization': f"Bearer {id_token}"
    }

    storage_client = storage.Client()

    temp_bucket = storage_client.bucket(TEMP_BUCKET_NAME)

    ar_object_list = get_object_list(temp_bucket,workflow_id)

    if not ar_object_list:
        return jsonify({"message": f"{workflow_id} data not found"}), 404
    
    ar_base64_encoded_audio = wave_to_base64(temp_bucket,ar_object_list)
    concatenated_audio_binary = concatenate_base64_encoded_wav_files(headers, ar_base64_encoded_audio)

    m4a_data_bynary = convert_wav_to_m4a(concatenated_audio_binary)
    upload_bucket = storage_client.bucket(UPLOAD_BUCKET_NAME)

    public_audio_url = upload_audio_bynary(upload_bucket,workflow_id,m4a_data_bynary)
    audio_duration = get_audio_duration_from_binary(concatenated_audio_binary)

    result = {
        'public_audio_url' : public_audio_url,
        'audio_duration' : audio_duration
    }

    return jsonify(result),200
