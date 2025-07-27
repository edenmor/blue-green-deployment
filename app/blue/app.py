from flask import Flask, jsonify
import os
import socket

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({
        'environment': 'Blue',
        'message': 'Blue environment is active!',
        'hostname': socket.gethostname(),
        'version': '1.0.0'
    })

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'environment': 'blue',
        'hostname': socket.gethostname()
    }), 200

@app.route('/info')
def info():
    return jsonify({
        'environment': 'Blue',
        'version': '1.0.0',
        'hostname': socket.gethostname(),
        'port': 5000,
        'description': 'Blue version of the application for blue-green deployment demo'
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
