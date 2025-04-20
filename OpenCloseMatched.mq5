#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 clrNONE

// === INPUT ===
input color    MatchLineColor    = clrGold;   // สีของเส้น
input int      MatchLineLength   = 3;         // ความยาวเส้น (จำนวนแท่ง)
input int      MaxDiffPoints     = 1;         // ความต่างราคาที่ถือว่า "เท่ากัน" (หน่วย point)
input double   MinBodyPoints     = 5;         // ความยาวแท่งขั้นต่ำ (body) หน่วย point

// === Dummy buffer (ไม่ใช้จริง แต่ป้องกัน warning)
double dummyBuffer[];

int OnInit()
{
   SetIndexBuffer(0, dummyBuffer, INDICATOR_DATA);
   return(INIT_SUCCEEDED);
}

// === คืนค่าเวลาต่อแท่งตาม Timeframe
int GetPeriodSeconds()
{
   return (int)PeriodSeconds(_Period);
}

// === วาดเส้นแนวนอนสั้นด้วย OBJ_TREND
void DrawShortLine(string name, double price, datetime time_start, color clr)
{
   datetime time_end = time_start + GetPeriodSeconds() * MatchLineLength;

   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_TREND, 0, time_start, price, time_end, price);
   }

   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(0, name, OBJPROP_RAY, false);
}

// === เงื่อนไขการกลับตัวแบบสมบูรณ์
bool IsStrictOpenCloseReversal(int i, const double &open[], const double &close[])
{
   if(i < 1) return false;

   double tolerance = MaxDiffPoints * _Point;
   double minBody   = MinBodyPoints * _Point;

   // ตรวจ body ต้องไม่สั้นเกิน
   double bodyPrev = MathAbs(close[i - 1] - open[i - 1]);
   double bodyCurr = MathAbs(close[i] - open[i]);
   if(bodyPrev < minBody || bodyCurr < minBody)
      return false;

   // หาทิศทางแท่ง
   bool isPrevBull = close[i - 1] > open[i - 1];
   bool isPrevBear = close[i - 1] < open[i - 1];
   bool isCurrBull = close[i] > open[i];
   bool isCurrBear = close[i] < open[i];

   // ถ้าไม่มีทิศทางแน่ชัด (Doji) → ตัด
   if((!isPrevBull && !isPrevBear) || (!isCurrBull && !isCurrBear))
      return false;

   // ต้องทิศทางตรงข้าม
   bool oppositeDirection = (isPrevBull && isCurrBear) || (isPrevBear && isCurrBull);
   if(!oppositeDirection)
      return false;

   // === ห้ามทะลุแนวกลับตัว ===
   if(isPrevBull && isCurrBear && close[i] > open[i - 1])
      return false;

   if(isPrevBear && isCurrBull && close[i] < open[i - 1])
      return false;

   // === ตรวจจับราคา match ข้ามแท่ง (ทุกแบบ)
   bool match1 = MathAbs(open[i - 1] - close[i]) <= tolerance;
   if(match1 && close[i] > open[i - 1]) return false;

   bool match2 = MathAbs(close[i - 1] - open[i]) <= tolerance;
   if(match2 && open[i] < close[i - 1]) return false;

   bool match3 = MathAbs(open[i] - close[i - 1]) <= tolerance;
   if(match3 && open[i] < close[i - 1]) return false;

   bool match4 = MathAbs(close[i] - open[i - 1]) <= tolerance;
   if(match4 && close[i] > open[i - 1]) return false;

   return match1 || match2 || match3 || match4;
}

// === OnCalculate ===
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int limit = rates_total - 2;

   for(int i = limit; i >= 1; i--)
   {
      if(IsStrictOpenCloseReversal(i, open, close))
      {
         double price = close[i];  // หรือ open[i]
         string line_id = "ReversalLine_" + IntegerToString(i) + "_" + TimeToString(time[i], TIME_SECONDS);
         DrawShortLine(line_id, price, time[i], MatchLineColor);
      }
   }

   return(rates_total);
}
