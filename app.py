"""
Sample Python Flask REST API Application
A simple TODO list API demonstrating REST endpoints
"""

from flask import Flask, request, jsonify
from datetime import datetime

app = Flask(__name__)

# In-memory storage (in production, use a database)
todos = []
todo_counter = 0


@app.route('/')
def index():
    """Health check endpoint"""
    return jsonify({
        'message': 'Welcome to the Sample Python TODO API',
        'version': '1.0.0',
        'endpoints': {
            'GET /todos': 'Get all todos',
            'POST /todos': 'Create a new todo',
            'GET /todos/<id>': 'Get a specific todo',
            'PUT /todos/<id>': 'Update a todo',
            'DELETE /todos/<id>': 'Delete a todo'
        }
    })


@app.route('/todos', methods=['GET'])
def get_todos():
    """Get all todos"""
    return jsonify({
        'todos': todos,
        'count': len(todos)
    })


@app.route('/todos', methods=['POST'])
def create_todo():
    """Create a new todo"""
    global todo_counter
    
    data = request.get_json()
    
    if not data or 'title' not in data:
        return jsonify({'error': 'Title is required'}), 400
    
    todo_counter += 1
    todo = {
        'id': todo_counter,
        'title': data['title'],
        'description': data.get('description', ''),
        'completed': False,
        'created_at': datetime.now().isoformat()
    }
    
    todos.append(todo)
    return jsonify(todo), 201


@app.route('/todos/<int:todo_id>', methods=['GET'])
def get_todo(todo_id):
    """Get a specific todo by ID"""
    todo = next((t for t in todos if t['id'] == todo_id), None)
    
    if not todo:
        return jsonify({'error': 'Todo not found'}), 404
    
    return jsonify(todo)


@app.route('/todos/<int:todo_id>', methods=['PUT'])
def update_todo(todo_id):
    """Update a todo"""
    todo = next((t for t in todos if t['id'] == todo_id), None)
    
    if not todo:
        return jsonify({'error': 'Todo not found'}), 404
    
    data = request.get_json()
    
    if 'title' in data:
        todo['title'] = data['title']
    if 'description' in data:
        todo['description'] = data['description']
    if 'completed' in data:
        todo['completed'] = data['completed']
    
    todo['updated_at'] = datetime.now().isoformat()
    
    return jsonify(todo)


@app.route('/todos/<int:todo_id>', methods=['DELETE'])
def delete_todo(todo_id):
    """Delete a todo"""
    global todos
    todo = next((t for t in todos if t['id'] == todo_id), None)
    
    if not todo:
        return jsonify({'error': 'Todo not found'}), 404
    
    todos = [t for t in todos if t['id'] != todo_id]
    return jsonify({'message': 'Todo deleted successfully'}), 200


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
