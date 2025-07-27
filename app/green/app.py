from flask import Flask, jsonify
import os
import socket

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({
        'environment': 'Green',
        'message': 'Green environment is active!',
        'hostname': socket.gethostname(),
        'version': '2.0.0'
    })

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'environment': 'green',
        'hostname': socket.gethostname()
    }), 200

@app.route('/info')
def info():
    return jsonify({
        'environment': 'Green',
        'version': '2.0.0',
        'hostname': socket.gethostname(),
        'port': 5000,
        'description': 'Green version of the application for blue-green deployment demo'
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
