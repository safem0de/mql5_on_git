from flask import Flask, request, jsonify
import datetime

app = Flask(__name__)

# ตัวแปรสำหรับเก็บข้อมูลชั่วคราว (ใน production ควรใช้ Database เช่น SQLite, PostgreSQL, MongoDB)
# ตัวอย่าง: เก็บข้อมูลราคาสุดท้าย หรือสัญญาณเทรด
last_received_data = {}
signals_to_send = [] # ตัวอย่าง: คิวของสัญญาณที่ Flask ต้องการส่งให้ MQL5

@app.route('/')
def home():
    return "Flask Server for MQL5 Integration is running!"

@app.route('/send_data', methods=['POST'])
def receive_data_from_mql5():
    """
    Endpoint สำหรับ MQL5 ส่งข้อมูลมายัง Flask
    MQL5 จะส่งเป็น POST request พร้อม JSON payload
    """
    if request.is_json:
        data = request.get_json()
        print(f"[{datetime.datetime.now()}] Received data from MQL5: {data}")

        # เก็บข้อมูลที่ได้รับไว้
        global last_received_data
        last_received_data = data

        # ตัวอย่าง: ประมวลผลข้อมูลที่ได้รับ
        # เช่น หาก MQL5 ส่งราคามา, Flask อาจจะวิเคราะห์และเตรียมสัญญาณตอบกลับ
        if 'symbol' in data and 'price' in data:
            print(f"Symbol: {data['symbol']}, Price: {data['price']}")
            # สมมติว่า Flask วิเคราะห์และตัดสินใจส่งสัญญาณ "BUY"
            # ในกรณีจริง คุณอาจจะประมวลผลด้วย Logic ที่ซับซ้อนกว่านี้
            if float(data['price']) < 1.0: # ตัวอย่างเงื่อนไข
                signals_to_send.append({"symbol": data['symbol'], "action": "BUY", "timestamp": str(datetime.datetime.now())})

        return jsonify({"status": "success", "message": "Data received successfully!"}), 200
    else:
        return jsonify({"status": "error", "message": "Request must be JSON"}), 400

@app.route('/get_data', methods=['GET'])
def send_data_to_mql5():
    """
    Endpoint สำหรับ MQL5 ดึงข้อมูลจาก Flask
    Flask จะส่ง JSON response กลับไป
    """
    global signals_to_send
    
    if signals_to_send:
        # ส่งสัญญาณที่ค้างอยู่ทั้งหมด แล้วล้างคิว
        data_to_send = signals_to_send
        signals_to_send = [] # Clear the queue after sending
        print(f"[{datetime.datetime.now()}] Sending data to MQL5: {data_to_send}")
        return jsonify({"status": "success", "data": data_to_send}), 200
    else:
        print(f"[{datetime.datetime.now()}] No new data to send to MQL5.")
        return jsonify({"status": "success", "data": []}), 200


@app.route('/get_last_received', methods=['GET'])
def get_last_received():
    """
    Endpoint สำหรับดูข้อมูลล่าสุดที่ได้รับจาก MQL5 (จากบราวเซอร์หรือ Postman)
    """
    return jsonify({"last_data": last_received_data})

if __name__ == '__main__':
    # รัน Flask server บนพอร์ต 5000 (ค่าเริ่มต้น)
    # Host '0.0.0.0' เพื่อให้สามารถเข้าถึงได้จากภายนอก (ในกรณีที่รันบนเครื่องอื่น)
    # หากรันบนเครื่องเดียวกันกับ MT5 ใช้ host '127.0.0.1' หรือ 'localhost' ก็ได้
    app.run(host='127.0.0.1', port=5000, debug=True) # debug=True สำหรับการพัฒนา