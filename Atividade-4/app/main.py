from pymongo import MongoClient
import os

client = MongoClient(os.getenv("MONGO_URI"))
db = client["library"]

authors = db["authors"]
books = db["books"]

print("\n📚 Books and their authors:\n")

for book in books.find():
    author = authors.find_one({"_id": book["author_id"]})
    print(f"Book: {book['title']} | Author: {author['name']}")