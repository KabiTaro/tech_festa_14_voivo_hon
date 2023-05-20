import re
from flask import jsonify
from dataclasses import dataclass, asdict, field


@dataclass
class OpenAIScriptStructure:
    speaker: str = field(init=False)
    text: str = field(init=False)
    step: int


ZUNDAMON_SPEAKER = 'ずんだもん'
METAN_SPEAKER = 'めたん'

ZUNDAMON_REGEX_PATTERN = r"^ずんだもん[:：](.*)$"
METAN_REGEX_PATTERN = r"^めたん[:：](.*)$"
REMOVE_REGEX_PATTERN = r'\([^)]*\)|（.*?）|「|」'


def main(request):
    request_json = request.get_json(silent=True)

    open_ai_text = request_json.get('open_ai_text')

    if open_ai_text is None:
        return jsonify({'message': 'open_ai_text is missing'}), 400

    ar_content = [re.sub(REMOVE_REGEX_PATTERN, '', text)
                  for text in open_ai_text.split("\n") if text != '']
    ar_return = []

    step = 1
    for content in ar_content:
        zunda_result = re.search(ZUNDAMON_REGEX_PATTERN, content)
        metan_result = re.search(METAN_REGEX_PATTERN, content)

        if zunda_result == None and metan_result == None:
            continue

        open_ai_script_structure = OpenAIScriptStructure(step=step)

        # ずんだもんが真の場合
        if zunda_result:
            open_ai_script_structure.speaker = ZUNDAMON_SPEAKER
            open_ai_script_structure.text = zunda_result.group(1)
        # めたんが真の場合
        elif metan_result:
            open_ai_script_structure.speaker = METAN_SPEAKER
            open_ai_script_structure.text = metan_result.group(1)

        ar_return.append(asdict(open_ai_script_structure))
        step += 1

    if not ar_return:
        return jsonify({'message': 'No matching data found'}), 404

    return jsonify(ar_return), 200
