# Sample Python Application

A simple Flask REST API for managing TODO items.

## Features

- Create, read, update, and delete TODO items
- RESTful API design
- JSON-based responses
- In-memory storage (for demo purposes)

## Installation

1. Create a virtual environment (recommended):
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

## Running the Application

```bash
python app.py
```

The API will be available at `http://localhost:5000`

## API Endpoints

### Health Check
- **GET** `/` - Returns API information

### TODO Operations
- **GET** `/todos` - Get all todos
- **POST** `/todos` - Create a new todo
  ```json
  {
    "title": "Sample task",
    "description": "Optional description"
  }
  ```
- **GET** `/todos/<id>` - Get a specific todo
- **PUT** `/todos/<id>` - Update a todo
  ```json
  {
    "title": "Updated title",
    "completed": true
  }
  ```
- **DELETE** `/todos/<id>` - Delete a todo

## Example Usage

### Create a TODO
```bash
curl -X POST http://localhost:5000/todos \
  -H "Content-Type: application/json" \
  -d '{"title": "Learn Python", "description": "Complete Python tutorial"}'
```

### Get all TODOs
```bash
curl http://localhost:5000/todos
```

### Update a TODO
```bash
curl -X PUT http://localhost:5000/todos/1 \
  -H "Content-Type: application/json" \
  -d '{"completed": true}'
```

### Delete a TODO
```bash
curl -X DELETE http://localhost:5000/todos/1
```

## Notes

- This is a sample application using in-memory storage
- Data will be lost when the server restarts
- For production use, integrate with a database (PostgreSQL, MongoDB, etc.)
