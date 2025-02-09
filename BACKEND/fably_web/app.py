from flask import Flask, request, render_template, redirect, url_for, flash, jsonify, session
from flask_login import LoginManager, login_user, login_required, logout_user, current_user
from pymongo import MongoClient
from werkzeug.security import generate_password_hash, check_password_hash
from flask_wtf.csrf import CSRFProtect
from bson import ObjectId
from datetime import datetime
import config
from models import Seller
from werkzeug.utils import secure_filename
import os
from cloudinary.uploader import upload
from cloudinary.utils import cloudinary_url
from cloudinary.api import delete_resources_by_prefix
from flask import Flask, jsonify
from flask_pymongo import PyMongo

import send_email as mail

app = Flask(__name__)

app.secret_key = 'f46a1ac2564717c33df1b0dcd5f2b336'

app.config['UPLOAD_FOLDER'] = 'static/uploads'
if not os.path.exists(app.config['UPLOAD_FOLDER']):
    os.makedirs(app.config['UPLOAD_FOLDER'])

app.config['SECRET_KEY'] = config.SECRET_KEY
csrf = CSRFProtect(app)

# MongoDB setup
client = MongoClient(config.MONGO_URI)
db = client.fably_db  # Database name
sellers_collection = db.sellers  # Seller/auth info
items_collection = db.items  # Item info
checkout_collection = db.checkouts  # Checkout data

# Login manager setup
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'

@login_manager.user_loader
def load_user(user_id):
    seller_data = sellers_collection.find_one({'_id': ObjectId(user_id)})
    return Seller(seller_data) if seller_data else None

# Allowed file types for uploads
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/')
def home():
    return render_template('index.html')

# ---------------- CHECKOUT FUNCTIONALITY ----------------

@app.route('/checkout', methods=['POST'])
def checkout():
    """Handles checkout form submission from Flutter"""
    try:
        data = request.get_json()
        
        # Validate required fields
        if not all(key in data for key in ["name", "address", "phone", "postalCode"]):
            return jsonify({"error": "Missing required fields"}), 400
        
        checkout_data = {
            "name": data["name"],
            "address": data["address"],
            "phone": data["phone"],
            "postalCode": data["postalCode"],
            "timestamp": datetime.utcnow()
        }
        
        checkout_collection.insert_one(checkout_data)
        return jsonify({"message": "Checkout successful!"}), 201
    
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route('/checkouts', methods=['GET'])
@login_required
def get_checkouts():
    """Retrieve all checkout records (Admin Only)"""
    checkouts = list(checkout_collection.find({}, {"_id": 0}))  # Exclude MongoDB _id
    return jsonify(checkouts)

# ---------------- SELLER & ITEM MANAGEMENT (UNCHANGED) ----------------

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        existing_user = sellers_collection.find_one({'email': request.form['email']})
        
        if existing_user is None:
            hashed_password = generate_password_hash(request.form['password'])
            sellers_collection.insert_one({
                'name': request.form['name'],
                'email': request.form['email'],
                'password': hashed_password,
                'phone': request.form['phone'],
                'created_date': datetime.utcnow()
            })
            body = f"""Hello, {request.form['name']}

Thank you for Signing Up to Fably!
"""
            mail.send_email(request.form["email"], "Registration to Fably", body)
            flash('Registration successful! Please login.', 'success')
            return redirect(url_for('login'))
        
        flash('Email already exists!', 'error')
    return render_template('register.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        seller = sellers_collection.find_one({'email': request.form['email']})
        
        if seller and check_password_hash(seller['password'], request.form['password']):
            user_obj = Seller(seller)
            login_user(user_obj)
            return redirect(url_for('dashboard'))
            
        flash('Invalid email or password!', 'error')
    return render_template('login.html')

@app.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('login'))

@app.route('/dashboard')
@login_required
def dashboard():
    seller_id = ObjectId(current_user.id) if isinstance(current_user.id, str) else current_user.id
    items = db.items.find({'seller_id': seller_id})
    return render_template('dashboard.html', items=items)


@app.route('/categories')
def get_categories():
    """Get all categories and subcategories"""
    categories = list(db.categories.find({}, {'_id': 1, 'name': 1, 'subcategories': 1}))
    return jsonify(categories)

# Add Items to DB
@app.route('/item/add', methods=['GET', 'POST'])
@login_required
def add_item():
    if request.method == 'POST':
        name = request.form.get('name')
        description = request.form.get('description')
        price = float(request.form.get('price'))
        category = request.form.get('category')
        stock_quantity = int(request.form.get('stock_quantity'))
        
        # Handle photo uploads
        photos = []
        if 'photos' in request.files:
            files = request.files.getlist('photos')
            for file in files:
                if file and allowed_file(file.filename):
                    upload_result = upload(file)
                    photos.append(upload_result['secure_url'])
        
        # Create item document
        item_data = {
            'seller_id': ObjectId(current_user.id),
            'name': name,
            'description': description,
            'price': price,
            'category': category,
            'photos': photos,
            'stock_quantity': stock_quantity,
            'created_at': datetime.utcnow(),
            'updated_at': datetime.utcnow()
        }
        
        db.items.insert_one(item_data)
        flash('Item added successfully!', 'success')
        return redirect(url_for('dashboard'))
    
    categories = list(db.categories.find())
    return render_template('add_item.html', categories=categories)


@app.route("/edit_item/<item_id>", methods=["GET", "POST"])
@login_required
def edit_item(item_id):
    item = items_collection.find_one({"_id": ObjectId(item_id)})
    
    if not item or item.get('seller_id') != ObjectId(current_user.id):
        flash('Item not found or you do not have permission to edit it.', 'error')
        return redirect(url_for("dashboard"))
    
    categories = list(db.categories.find())

    if request.method == "POST":
        updated_data = {
            "name": request.form.get("name"),
            "description": request.form.get("description"),
            "price": float(request.form.get("price")),
            "category": request.form.get("category"),
            "stock_quantity": int(request.form.get("stock_quantity")),
            "updated_at": datetime.utcnow()
        }
        
        result = items_collection.update_one(
            {
                "_id": ObjectId(item_id), 
                "seller_id": ObjectId(current_user.id)
            }, 
            {"$set": updated_data}
        )
        
        flash('Item updated successfully!' if result.modified_count > 0 else 'No changes made.', 'success')
        return redirect(url_for("dashboard"))

    return render_template("edit_item.html", item=item, categories=categories)

@app.route("/delete_item/<item_id>", methods=["POST"])
@login_required
def delete_item(item_id):
    item = items_collection.find_one({"_id": ObjectId(item_id), "seller_id": ObjectId(current_user.id)})
    
    if not item:
        flash('Item not found.', 'error')
        return redirect(url_for("dashboard"))

    # Delete Cloudinary images
    for img_url in item.get('photos', []):
        public_id = img_url.split("/")[-1].split(".")[0]  # Extract public ID
        delete_resources_by_prefix(public_id)

    # Delete from MongoDB
    result = items_collection.delete_one({"_id": ObjectId(item_id)})
    
    flash('Item deleted successfully!' if result.deleted_count else 'Item not found.', 'success')
    return redirect(url_for("dashboard"))

# returns the items as a JSON response
@app.route('/products', methods=['GET'])
def get_products():
    try:
        # Fetch the items from the collection
        items = list(items_collection.find({}, {"_id": 1, "name": 1, "price": 1}))  # Example: also include other fields like 'name' or 'price'
        
        # Convert ObjectId to string
        for item in items:
            item["_id"] = str(item["_id"])
        
        return jsonify(items)
    
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
