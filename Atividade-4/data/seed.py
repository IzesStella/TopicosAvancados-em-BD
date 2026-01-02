from pymongo import MongoClient
import os

client = MongoClient(os.getenv("MONGO_URI"))
db = client["library"]

authors = db["authors"]
books = db["books"]

authors.delete_many({})
books.delete_many({})

author1 = authors.insert_one({
    "name": "George Orwell",
    "country": "United Kingdom"
}).inserted_id

author2 = authors.insert_one({
    "name": "J.K. Rowling",
    "country": "United Kingdom"
}).inserted_id

books.insert_many([
    {
        "title": "1984",
        "author_id": author1
    },
    {
        "title": "Animal Farm",
        "author_id": author1
    },
    {
        "title": "Harry Potter",
        "author_id": author2
    }
])

print("✅ Dados inseridos com sucesso!")
