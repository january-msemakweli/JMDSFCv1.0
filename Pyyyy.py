from flask import Flask, render_template, request, jsonify, send_file
import pandas as pd
import folium
import os
from io import BytesIO
import csv
from werkzeug.utils import secure_filename

app = Flask(__name__)

# Store GPS Data in memory (mock database)
gps_data = []

# Root directory for file uploads and downloads
UPLOAD_FOLDER = './uploads'
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

# Ensure the uploaded file type is allowed
ALLOWED_EXTENSIONS = {'csv', 'xlsx', 'xls', 'sas7bdat', 'sav', 'dta', 'rdata'}
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER


def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


@app.route('/')
def index():
    # Display the main page
    return render_template('index.html')


@app.route('/upload_dataset', methods=['POST'])
def upload_dataset():
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'})

    file = request.files['file']

    if file.filename == '':
        return jsonify({'error': 'No selected file'})

    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(file_path)

        # Load dataset into a Pandas DataFrame based on file extension
        ext = filename.rsplit('.', 1)[1].lower()
        if ext == 'csv':
            df = pd.read_csv(file_path)
        elif ext in ['xlsx', 'xls']:
            df = pd.read_excel(file_path)
        # Add other file type handling as needed (SAS, SPSS, Stata, RData)

        # Display preview of the dataset
        return jsonify({'columns': df.columns.tolist(), 'data': df.head(10).to_dict(orient='records')})

    return jsonify({'error': 'File type not allowed'})


@app.route('/convert_dataset', methods=['POST'])
def convert_dataset():
    file_path = request.form['file_path']
    output_format = request.form['output_format']
    df = pd.read_csv(file_path)  # Assuming CSV as the default input format

    # Convert based on requested output format
    output = BytesIO()
    if output_format == 'csv':
        df.to_csv(output, index=False)
        output.seek(0)
        return send_file(output, attachment_filename='converted_dataset.csv', as_attachment=True)

    elif output_format == 'xlsx':
        with pd.ExcelWriter(output, engine='openpyxl') as writer:
            df.to_excel(writer, index=False)
        output.seek(0)
        return send_file(output, attachment_filename='converted_dataset.xlsx', as_attachment=True)

    return jsonify({'error': 'Unsupported format'})


@app.route('/add_gps_point', methods=['POST'])
def add_gps_point():
    lat = request.json.get('latitude')
    lon = request.json.get('longitude')

    if lat is None or lon is None:
        return jsonify({'error': 'Invalid GPS coordinates'})

    # Add new GPS point
    gps_data.append({'ID': len(gps_data) + 1, 'Latitude': round(lat, 11), 'Longitude': round(lon, 11)})
    return jsonify({'message': 'GPS point added', 'data': gps_data})


@app.route('/delete_gps_point', methods=['POST'])
def delete_gps_point():
    point_id = request.json.get('id')

    # Delete the point based on ID
    global gps_data
    gps_data = [point for point in gps_data if point['ID'] != point_id]

    return jsonify({'message': 'GPS point deleted', 'data': gps_data})


@app.route('/gps_data', methods=['GET'])
def get_gps_data():
    return jsonify(gps_data)


@app.route('/download_gps', methods=['GET'])
def download_gps():
    # Download GPS data as a CSV file
    output = BytesIO()
    writer = csv.DictWriter(output, fieldnames=['ID', 'Latitude', 'Longitude'])
    writer.writeheader()
    writer.writerows(gps_data)
    output.seek(0)
    return send_file(output, attachment_filename='gps_data.csv', as_attachment=True)


@app.route('/gps_map', methods=['GET'])
def gps_map():
    # Create map
    gps_map = folium.Map(location=[0, 0], zoom_start=2)

    # Add GPS points to the map
    for point in gps_data:
        folium.Marker([point['Latitude'], point['Longitude']], popup=f"ID: {point['ID']}").add_to(gps_map)

    # Save the map to HTML
    gps_map.save('./templates/gps_map.html')

    return render_template('gps_map.html')


if __name__ == '__main__':
    app.run(debug=True)
