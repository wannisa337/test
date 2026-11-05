# SauceDemo - Robot Framework + Excel + YAML

โปรเจกต์ตัวอย่างสำหรับทดสอบเว็บ https://www.saucedemo.com/ ด้วย Robot Framework โดยแยกข้อมูลเป็น 3 ส่วน

- `config.yaml` เก็บ URL, browser, headless, timeout และบัญชีเริ่มต้น
- `TestData.xlsx` เก็บ Test Data แยกตาม Test Case
- `tests/saucedemo.robot` เก็บขั้นตอนทดสอบ โดยใช้ DataDriver อ่านข้อมูลจาก Excel

## 1) เตรียมเครื่อง

แนะนำ Python 3.10 ขึ้นไป และติดตั้ง Google Chrome

เปิด Terminal ในโฟลเดอร์โปรเจกต์ แล้วรัน:

```bash
python -m venv .venv
```

Windows:
```bash
.venv\\Scripts\\activate
```

macOS/Linux:
```bash
source .venv/bin/activate
```

ติดตั้งไลบรารี:
```bash
pip install -r requirements.txt
```

Selenium Manager ของ Selenium จะช่วยจัดการ ChromeDriver ให้ในกรณีที่สภาพแวดล้อมรองรับ

## 2) โครงสร้างไฟล์

```text
SauceDemo_RobotFramework/
├── config.yaml
├── config_variables.py
├── TestData.xlsx
├── requirements.txt
├── README_TH.md
└── tests/
    └── saucedemo.robot
```

## 3) รูปแบบ Excel

ชีตชื่อ `TestData` โดยมีคอลัมน์:
- `*** Test Cases ***` = ชื่อ Test Case
- `${scenario}` = ประเภทสถานการณ์ที่ต้องการรัน
- `${username}`, `${password}` = ข้อมูลล็อกอิน
- `${items_to_add}` = ชื่อสินค้า คั่นหลายรายการด้วย comma
- `${first_name}`, `${last_name}`, `${postal_code}` = ข้อมูล Checkout
- `${expected_result}` = ผลลัพธ์ที่คาดหวัง

คอลัมน์ `${scenario}` เพิ่มเข้ามาเพื่อให้ Robot เลือก keyword ให้ตรงกับกรณีทดสอบได้ ส่วนคอลัมน์อื่นเป็นข้อมูลตามโจทย์

## 4) Scenario ที่เตรียมไว้

1. ซื้อสินค้าสำเร็จ โดยเพิ่มสินค้าหลายรายการ
2. เข้าสู่ระบบด้วย locked_out_user
3. เข้าสู่ระบบด้วย username/password ไม่ถูกต้อง
4. Checkout โดยไม่กรอก First Name
5. Checkout โดยไม่กรอก Last Name
6. Checkout โดยไม่กรอก Postal Code
7. ลบสินค้าออกจาก Cart
8. เรียงราคาสินค้าจากต่ำไปสูง

บัญชีทดสอบมาตรฐานของ SauceDemo ใช้ `secret_sauce` เป็นรหัสผ่าน ตัวอย่างข้อมูลนี้ใช้เพื่อการเรียนและทดสอบเท่านั้น

## 5) วิธีรัน

จากโฟลเดอร์หลัก:

```bash
robot --outputdir results tests/saucedemo.robot
```

เปิดรายงาน:
- `results/report.html`
- `results/log.html`
- `results/output.xml`

หากต้องการทดสอบแบบไม่แสดงหน้าต่าง Chrome ให้แก้ `headless: true` ใน `config.yaml`

## 6) อธิบายหลักการทำงาน

- DataDriver อ่านแต่ละแถวใน Excel แล้วสร้าง Test Case แยกตามชื่อในคอลัมน์ `*** Test Cases ***`
- Test Template กำหนดให้ทุกแถวเรียก `Run Test Scenario`
- `${scenario}` ใช้เลือกเส้นทางการทดสอบ เช่น `purchase_success` หรือ `invalid_login`
- `Add Items To Cart` ใช้ `Split String` แยกรายการสินค้าด้วย comma แล้ววนลูปเพิ่มทีละรายการ
- `config_variables.py` อ่าน YAML แล้วส่งค่าออกมาเป็น Robot variables เช่น `${BASE_URL}` และ `${EXPLICIT_WAIT}`

## 7) หมายเหตุ

- ชื่อสินค้าใน Excel ต้องตรงกับชื่อสินค้าที่แสดงบนหน้า SauceDemo เช่น `Sauce Labs Backpack`
- ถ้าเว็บมีการเปลี่ยนข้อความแจ้งเตือนหรือหน้าจอ ให้ปรับ `expected_result` หรือ locator ให้ตรงกับเว็บเวอร์ชันที่ทดสอบ
- `locked_out_user` เป็นบัญชีที่ตั้งใจให้ล็อกอินไม่ได้ จึงคาดหวังข้อความแจ้งเตือน ไม่ใช่การซื้อสินค้า
- กรณี Cart Remove จะตรวจจำนวนรายการก่อนและหลังลบ ส่วน `${expected_result}` ใช้เป็นค่าตรวจสอบเพิ่มเติมตามตัวอย่างใน Excel
