import os
import re
from flask import Flask, request, render_template, send_file, Response, abort

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = 'uploads'
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024 # 16MB max upload

# Ensure upload directory exists
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

# FLAG3_04{s0urc3_c0d3_r3v34l3d} - Developer note: Remember to remove debug flags before production

def is_safe_path(basedir, path, follow_symlinks=True):
    # This is intentionally broken for LFI
    return True

@app.after_request
def add_header(response):
    response.headers['X-LPH-Logistics-ID'] = 'FLAG3_01{h1dd3n_l0g1st1cs_p0rt4l}'
    return response

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/download')
def download_file():
    document = request.args.get('document')
    if not document:
        return "Missing document parameter", 400
    
    # Intentionally vulnerable to LFI
    file_path = os.path.join(app.root_path, document)
    
    try:
        return send_file(file_path, as_attachment=True)
    except FileNotFoundError:
        # FLAG3_02: Verbose error
        return f"Error: The requested file '{file_path}' was not found. FLAG3_02{{v3rb0s3_3rr0r_d1scl0sur3}}", 404
    except Exception as e:
        return str(e), 500

@app.route('/upload_report', methods=['POST'])
def upload_file():
    if 'report' not in request.files:
        return "No report part", 400
    file = request.files['report']
    if file.filename == '':
        return "No selected file", 400
        
    filename = file.filename
    
    # Weak filter to bypass
    if '../' in filename:
        return "SECURITY ALERT: Path traversal attempt detected. Incident logged. FLAG3_05{b4s1c_f1lt3r_tr1gg3r3d}", 403
        
    # Vulnerable save - allows arbitrary file write if filter is bypassed (e.g., using ....//)
    # The fix is to use werkzeug.utils.secure_filename, but we intentionally don't here
    
    # Normalize path somewhat to allow bypass to work
    filename = filename.replace('....//', '../')
    save_path = os.path.join(app.root_path, app.config['UPLOAD_FOLDER'], filename)
    
    try:
        file.save(save_path)
        
        # Check if the test file was overwritten for FLAG 6
        if save_path == os.path.join(app.root_path, 'test.txt'):
             return "File uploaded successfully. FLAG3_06{4rb1tr4ry_f1l3_wr1t3_c0nf1rm3d}", 200
             
        return f"File {filename} uploaded successfully.", 200
    except Exception as e:
        return f"Upload failed: {str(e)}", 500

@app.route('/maintenance')
def maintenance():
    # This template will be overwritten via arbitrary file write
    return render_template('maintenance.html')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
