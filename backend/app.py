from flask import Flask, request
import speech_recognition as sr


app = Flask(__name__)


@app.route("/transcribe", methods=["POST"])
def transcribe():
    file = request.files.get("audio")
    file.save(file.filename)
    r = sr.Recognizer()
    with sr.AudioFile(file.filename) as source:
        audio = r.record(source)

    try:
        return r.recognize_google(audio), 200
    except sr.UnknownValueError:
        return "Google Speech Recognition Services could not understand audio", 404
    except sr.RequestError as e:
        return (
            "Could not request results from Google Speech Recognition service; {0}".format(
                e
            ),
            404,
        )


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0")
