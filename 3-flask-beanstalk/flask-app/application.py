from flask import Flask, jsonify, request

app = Flask(__name__)

# Sample route for the home page
@app.route('/')
def home():
    return jsonify(message="Welcome to the Flask app on Elastic Beanstalk!")

# A sample route that accepts GET requests
@app.route('/api/data', methods=['GET'])
def get_data():
    sample_data = {
        "id": 1,
        "name": "Sample Item",
        "description": "This is a sample item for demonstration purposes."
    }
    return jsonify(sample_data)

# A sample route that accepts POST requests
@app.route('/api/data', methods=['POST'])
def create_data():
    data = request.get_json()
    return jsonify(message="Data received successfully!", data=data), 201

if __name__ == '__main__':
    # The app listens on 0.0.0.0:5000 to match AWS Elastic Beanstalk's configuration
    app.run(host='0.0.0.0', port=5000)
