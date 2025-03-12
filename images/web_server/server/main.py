from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def root_get():
    return {"message": "Hello from the GET method!"}

@app.post("/")
def root_post():
    return {"message": "Hello from the POST method!"}

@app.put("/")
def root_put():
    return {"message": "Hello from the PUT method!"}

@app.delete("/")
def root_delete():
    return {"message": "Hello from the DELETE method!"}