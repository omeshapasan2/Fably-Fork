from dotenv import load_dotenv
import os

load_dotenv()

#MONGO_URI = os.getenv('MONGO_URI')#
MONGO_URI = "mongodb+srv://FablyUser:qO4UZo2U1xszuv17@fably-data.m3ceo.mongodb.net/?retryWrites=true&w=majority&appName=Fably-data"
SECRET_KEY = os.getenv('f46a1ac2564717c33df1b0dcd5f2b336')

# Cloudinary Configuration
CLOUDINARY_CLOUD_NAME = os.getenv('CLOUDINARY_CLOUD_NAME')
CLOUDINARY_API_KEY = os.getenv('CLOUDINARY_API_KEY')
CLOUDINARY_API_SECRET = os.getenv('CLOUDINARY_API_SECRET')