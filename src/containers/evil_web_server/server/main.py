from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def root_get():
    return {"message": "Evil GET greetings!"}

@app.post("/")
def root_post():
    return {"message": "Evil POST greetings!"}

@app.put("/")
def root_put():
    return {"message": "Evil PUT greetings!"}

@app.delete("/")
def root_delete():
    return {"message": "Evil DELETE greetings!"}