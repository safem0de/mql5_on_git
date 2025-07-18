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
   //--- GET ---//
  
   string url = "http://127.0.0.1:5000/get_last_received";
   string headers = "";   // ไม่มี header ก็ส่ง string ว่าง
   uchar data[];          // <-- ต้องเป็น uchar[] (array เปล่าก็ได้)
   uchar result[];        // ผลลัพธ์
   string response;
   ResetLastError();
   int res = WebRequest("GET", url, headers, 5000, data, result, response);

   Print("WebRequest result: ", res, " | LastError: ", GetLastError());
   string sres = CharArrayToString(result);
   Print("Response: ", sres);
  }
