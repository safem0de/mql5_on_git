int WebRequest(
   const string method,   // เช่น "GET" หรือ "POST"
   const string url,      // URL
   const string headers,  // headers string
   int timeout,           // ms
   const uchar &data[],   // payload data (หรือ NULL ถ้า GET)
   uchar &result[],       // เก็บผลลัพธ์
   string &response       // debug info
   );

void OnStart()
  {
   //--- POST ---//
  
   string url = "http://127.0.0.1:5000/send_data";
   string headers = "Content-Type: application/json\r\n"; // บอกว่าเราส่ง JSON

   // เตรียม JSON payload (แก้ไขตามข้อมูลที่ต้องการ)
   string payload = "{"
                    "\"symbol\":\"EURJPY\","
                    "\"price\":143.76"
                    "}";

   uchar data[];
   StringToCharArray(payload, data, 0, StringLen(payload), CP_UTF8); // แปลง string เป็น uchar[] UTF-16 (สำหรับ WebRequest)
   
   uchar result[];
   string response;
   ResetLastError();
   int res = WebRequest("POST", url, headers, 5000, data, result, response);

   Print("WebRequest result: ", res, " | LastError: ", GetLastError());
   string sres = CharArrayToString(result);
   Print("Response: ", sres);
 }