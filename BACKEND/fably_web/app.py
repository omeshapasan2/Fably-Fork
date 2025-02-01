from flask import Flask, request, render_template, redirect, url_for, flash, jsonify
from flask_login import LoginManager, login_user, login_required, logout_user, current_user
from pymongo import MongoClient
from werkzeug.security import generate_password_hash, check_password_hash
from flask_wtf.csrf import CSRFProtect
from bson import ObjectId
from datetime import datetime
import config
from models import Seller
from flask import render_template
from forms import AddItemForm
from werkzeug.utils import secure_filename
import os
from flask import Flask, session
from flask_login import LoginManager
from flask_login import login_required, current_user


app = Flask(__name__)

app.secret_key = 'f46a1ac2564717c33df1b0dcd5f2b336'

app.config['UPLOAD_FOLDER'] = 'static/uploads'
if not os.path.exists(app.config['UPLOAD_FOLDER']):
    os.makedirs(app.config['UPLOAD_FOLDER'])


app.config['SECRET_KEY'] = config.SECRET_KEY
csrf = CSRFProtect(app)

# MongoDB setup
client = MongoClient(config.MONGO_URI)
db = client.fably_db  # database name
sellers_collection = db.sellers # collection/table for seller/auth info
items_collection = db.items # collection/table for item info

# Login manager setup
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'

@login_manager.user_loader
def load_user(user_id):
    seller_data = sellers_collection.find_one({'_id': ObjectId(user_id)})
    return Seller(seller_data) if seller_data else None

# Add near the top of your file with other imports and configurations
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

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

    # Fetch items added by the logged-in user
    user_id = session["user_id"]
    items = list(items_collection.find({"user_id": user_id}))

    return render_template("dashboard.html", items=items)


@app.route('/categories')
def get_categories():
    """Get all categories and subcategories"""
    categories = list(db.categories.find({}, {'_id': 1, 'name': 1, 'subcategories': 1}))
    return jsonify(categories)

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
                    filename = secure_filename(f"{datetime.utcnow().timestamp()}_{file.filename}")
                    filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
                    file.save(filepath)
                    photos.append(f"/static/uploads/{filename}")
        
        # Create item document with clothing-specific fields
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
    
    # Get categories for the form
    categories = list(db.categories.find())
    return render_template('add_item.html', categories=categories)

@app.route("/edit_item/<item_id>", methods=["GET", "POST"])
@login_required
def edit_item(item_id):
    # Get the item and verify ownership
    item = items_collection.find_one({"_id": ObjectId(item_id)})
    
    if not item or item.get('seller_id') != ObjectId(current_user.id):
        flash('Item not found or you do not have permission to edit it.', 'error')
        return redirect(url_for("dashboard"))
    
    # Get categories for the form
    categories = list(db.categories.find())

    if request.method == "POST":
        # Update the item in the database
        updated_data = {
            "name": request.form.get("name"),
            "description": request.form.get("description"),
            "price": float(request.form.get("price")),
            "category": request.form.get("category"),
            "stock_quantity": int(request.form.get("stock_quantity")),
            "updated_at": datetime.utcnow()
        }
        
        # Fixed: Use ObjectId for seller_id in the query
        result = items_collection.update_one(
            {
                "_id": ObjectId(item_id), 
                "seller_id": ObjectId(current_user.id)
            }, 
            {"$set": updated_data}
        )
        
        if result.modified_count > 0:
            flash('Item updated successfully!', 'success')
        else:
            flash('No changes were made to the item.', 'info')
            
        return redirect(url_for("dashboard"))

    return render_template("edit_item.html", item=item, categories=categories)

@app.route("/delete_item/<item_id>", methods=["POST"])
@login_required
def delete_item(item_id):
    # Verify ownership and delete
    result = items_collection.delete_one({
        "_id": ObjectId(item_id),
        "seller_id": ObjectId(current_user.id)
    })
    
    if result.deleted_count:
        flash('Item deleted successfully!', 'success')
    else:
        flash('Item not found or you do not have permission to delete it.', 'error')
    
    return redirect(url_for("dashboard"))

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
