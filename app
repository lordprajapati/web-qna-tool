from flask import Flask, request, jsonify, render_template
from bs4 import BeautifulSoup
import requests
import openai

app = Flask(__name__)

# Store ingested content
ingested_data = {}

@app.route('/')
def home():
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <title>Web Q&A Tool</title>
        <script>
            async function ingestUrls() {
                let urls = document.getElementById("urls").value.split("\n");
                let response = await fetch("/ingest", {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({ urls })
                });
                let result = await response.json();
                alert(result.message);
            }
            
            async function askQuestion() {
                let question = document.getElementById("question").value;
                let response = await fetch("/ask", {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({ question })
                });
                let result = await response.json();
                document.getElementById("answer").innerText = result.answer;
            }
        </script>
    </head>
    <body>
        <h1>Web Q&A Tool</h1>
        <textarea id="urls" placeholder="Enter URLs (one per line)"></textarea>
        <button onclick="ingestUrls()">Ingest URLs</button>
        <br><br>
        <input id="question" type="text" placeholder="Ask a question">
        <button onclick="askQuestion()">Ask</button>
        <p id="answer"></p>
    </body>
    </html>
    '''

@app.route('/ingest', methods=['POST'])
def ingest():
    urls = request.json.get("urls", [])
    global ingested_data
    ingested_data = {}
    
    for url in urls:
        try:
            response = requests.get(url)
            soup = BeautifulSoup(response.text, "html.parser")
            ingested_data[url] = soup.get_text()
        except Exception as e:
            ingested_data[url] = f"Error fetching content: {e}"
    
    return jsonify({"message": "Content ingested successfully"})

@app.route('/ask', methods=['POST'])
def ask():
    question = request.json.get("question", "")
    combined_text = "\n".join(ingested_data.values())
    
    # Mocking response (Use GPT API if available)
    response = f"Based on the ingested content, the answer is: {question[:50]}... (example)"
    
    return jsonify({"answer": response})

if __name__ == '__main__':
    app.run(debug=True)
