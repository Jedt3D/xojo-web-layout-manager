# DesktopLayoutManager - ไลบรารี Xojo Flex Layout

ไลบรารีจัดการเลย์เอาต์ที่ทรงพลังและยืดหยุ่นสำหรับแอปพลิเคชัน Xojo Desktop ซึ่งนำความสามารถบางส่วนของ CSS Flexbox มาใช้งาน ช่วยให้สามารถออกแบบ UI ที่ตอบสนองและปรับเปลี่ยนได้ด้วยโค้ดที่น้อยที่สุด

## ภาพรวม

`DesktopLayoutManager` เป็นคลาส Xojo แบบกำหนดเองที่นำความสามารถในการจัดวางเลย์เอาต์แบบ flexbox สมัยใหม่มาสู่แอปพลิเคชันเดสก์ท็อป โดยจัดเตรียมการจัดตำแหน่งและปรับขนาดของตัวควบคุม UI (UI controls) อัตโนมัติตามกฎเลย์เอาต์ที่กำหนดค่าได้ ช่วยขจัดความจำเป็นในการจัดตำแหน่งด้วยตนเองและตรรกะการปรับขนาดที่ซับซ้อน

## คุณสมบัติหลัก

### 🎯 ความสามารถในการจัดเลย์เอาต์หลัก
- **ทิศทาง Flex (Flex Direction)**: รองรับทั้งเลย์เอาต์แนวนอน (Row) และแนวตั้ง (Column)
- **การขยาย Flex (Flex Grow)**: การปรับขนาดตัวควบคุมแบบไดนามิกเพื่อเติมเต็มพื้นที่ว่างตามสัดส่วน
- **การจัดตำแหน่งเนื้อหา (Justify Content)**: การจัดตำแหน่งตามแนวแกนหลัก (FlexStart, FlexEnd, Center, SpaceBetween, SpaceAround, Stretch)
- **การจัดตำแหน่งไอเท็ม (Align Items)**: การจัดตำแหน่งตามแนวแกนรอง (FlexStart, FlexEnd, Center, Stretch)
- **ระยะห่าง (Spacing)**: กำหนดค่าช่องว่าง (gaps) ระหว่างตัวควบคุมและระยะขอบด้านใน (padding) รอบคอนเทนเนอร์ได้

### 🛠️ การรวมเข้าด้วยกันที่ง่ายดาย
- **รองรับ Visual Designer**: คุณสมบัติทั้งหมดสามารถกำหนดค่าได้โดยตรงใน Xojo Inspector
- **การควบคุมขณะรันไทม์ (Runtime Control)**: สามารถเพิ่ม/ลบตัวควบคุมและอัปเดตเลย์เอาต์แบบไดนามิก
- **ปรับขนาดอัตโนมัติ (Automatic Resizing)**: เลย์เอาต์จะปรับตามการเปลี่ยนแปลงขนาดของคอนเทนเนอร์โดยอัตโนมัติ
- **การจัดการการมองเห็น (Visibility Handling)**: ตัวควบคุมที่ถูกซ่อนจะถูกตัดออกจากการคำนวณเลย์เอาต์โดยอัตโนมัติ

### ⚡ ปรับแต่งประสิทธิภาพ
- **อัลกอริทึมที่มีประสิทธิภาพ**: คำนวณเลย์เอาต์ในรอบเดียว (Single-pass) โดยใช้ทรัพยากรน้อยที่สุด
- **การอัปเดตที่ชาญฉลาด**: คำนวณใหม่เฉพาะเมื่อจำเป็นเท่านั้น
- **ประหยัดหน่วยความจำ**: ใช้ dictionary เพื่อการค้นหาค่า flex-grow factor อย่างรวดเร็ว

## เริ่มต้นใช้งานด่วน

```xojo
// สร้าง layout manager
Var layoutManager As New DesktopFlexLayoutManager()
layoutManager.Left = 0
layoutManager.Top = 0
layoutManager.Width = Self.Width
layoutManager.Height = 100

// กำหนดค่าคุณสมบัติของเลย์เอาต์
layoutManager.Direction = FlexDirection.Row
layoutManager.Justify = JustifyContent.SpaceBetween
layoutManager.Align = AlignItems.Center
layoutManager.Gap = 10
layoutManager.PaddingLeft = 20
layoutManager.PaddingRight = 20

// เพิ่มตัวควบคุมพร้อมกำหนดค่า flex-grow
layoutManager.AddControl(button1, 0)  // ขนาดคงที่
layoutManager.AddControl(button2, 1)  // ขยายเพื่อเติมเต็มพื้นที่ว่าง
layoutManager.AddControl(button3, 2)  // ขยายเป็นสองเท่าของ button2

// นำเลย์เอาต์ไปใช้งาน
layoutManager.ApplyLayout()

// อัปเดตเมื่อมีการปรับขนาด
AddHandler Self.Resized, Sub() layoutManager.ApplyLayout()
```

## สถาปัตยกรรม

### โครงสร้างคลาส
```
DesktopFlexLayoutManager
├── Properties (คุณสมบัติ)
│   ├── Direction (FlexDirection)
│   ├── Justify (JustifyContent)
│   ├── Align (AlignItems)
│   ├── Gap (Integer)
│   └── Padding* (Integer)
├── Methods (เมธอด)
│   ├── AddControl(control, growFactor)
│   ├── SetFlexGrow(control, growFactor)
│   └── ApplyLayout()
└── Internal (ภายใน)
    ├── ManagedControls() Array
    └── FlexGrowMap Dictionary
```

### อัลกอริทึมของเลย์เอาต์
เอนจินเลย์เอาต์ทำงานตามกระบวนการ 5 ขั้นตอน:

1. **รวบรวมตัวชี้วัด (Gather Metrics)**: รวบรวมตัวควบคุมที่มองเห็นได้และคำนวณความต้องการพื้นที่คงที่
2. **คำนวณพื้นที่ว่าง (Calculate Available Space)**: กำหนดพื้นที่ที่ใช้งานได้หลังจากหักระยะขอบด้านในและช่องว่างแล้ว
3. **กระจาย Flex Grow (Distribute Flex Grow)**: จัดสรรพื้นที่ที่เหลือให้กับตัวควบคุมที่ขยายได้ตามสัดส่วน
4. **นำ Justify Content ไปใช้ (Apply Justify Content)**: จัดตำแหน่งตัวควบคุมตามแนวแกนหลัก
5. **นำตำแหน่งและ Align Items ไปใช้ (Apply Positions & Align Items)**: กำหนดตำแหน่งสุดท้ายและการจัดตำแหน่งตามแนวแกนรอง

## ตัวอย่างการใช้งาน

### แถบนำทางแนวนอน
```xojo
navLayout.Direction = FlexDirection.Row
navLayout.Justify = JustifyContent.SpaceBetween
navLayout.Align = AlignItems.Center
navLayout.AddControl(homeButton, 0)
navLayout.AddControl(searchField, 1)  // ขยายเพื่อเติมเต็มพื้นที่ว่าง
navLayout.AddControl(userMenu, 0)
```

### แผงการตั้งค่าแนวตั้ง
```xojo
settingsLayout.Direction = FlexDirection.Column
settingsLayout.Justify = JustifyContent.FlexStart
settingsLayout.Align = AlignItems.Stretch
settingsLayout.AddControl(titleSection, 0)
settingsLayout.AddControl(optionsGroup, 1)  // ขยายในแนวตั้ง
settingsLayout.AddControl(buttonBar, 0)
```

### กริดที่ตอบสนอง
```xojo
// สร้าง layout manager หลายตัวสำหรับหน้าจอขนาดต่างๆ
If Self.Width > 800 Then
    mainLayout.Direction = FlexDirection.Row
Else
    mainLayout.Direction = FlexDirection.Column
End If
```

## คุณสมบัติใหม่ที่แนะนำ

### 🚀 ความสำคัญระดับสูง
- **รองรับการตัดขึ้นบรรทัดใหม่ (Wrap Support)**: เลย์เอาต์หลายบรรทัด/หลายคอลัมน์เมื่อไอเท็มล้นขอบเขต
- **การหดตัว Flex (Flex Shrink)**: ควบคุมวิธีที่ไอเท็มหดตัวเมื่อพื้นที่มีจำกัด
- **ขนาดต่ำสุด/สูงสุด (Minimum/Maximum Sizes)**: ข้อจำกัดขนาดของแต่ละตัวควบคุม
- **การจัดตำแหน่งตนเอง (Alignment Self)**: การแทนที่การจัดตำแหน่งสำหรับตัวควบคุมแต่ละตัว

### 🔧 ความสำคัญระดับกลาง
- **เลย์เอาต์ซ้อนกัน (Nested Layouts)**: รองรับการใช้ layout manager ภายใน layout manager อื่น
- **รองรับแอนิเมชัน (Animation Support)**: การเปลี่ยนภาพที่ราบรื่นระหว่างการเปลี่ยนแปลงเลย์เอาต์
- **เหตุการณ์เลย์เอาต์ (Layout Events)**: คอลแบ็ก (Callbacks) สำหรับการเริ่มต้น/เสร็จสิ้นการจัดเลย์เอาต์
- **โหมดดีบัก (Debug Mode)**: แสดงภาพซ้อนทับเพื่อดูขอบเขตของเลย์เอาต์และการคำนวณ

### 🎨 ความสำคัญระดับต่ำ
- **รองรับ RTL (RTL Support)**: ทิศทางเลย์เอาต์จากขวาไปซ้าย
- **การจัดตำแหน่งตามเส้นฐาน (Baseline Alignment)**: จัดตำแหน่งไอเท็มตามเส้นฐานของข้อความ
- **แยกช่องว่าง (Gap Separation)**: กำหนดช่องว่างแนวนอนและแนวตั้งที่แตกต่างกัน
- **ปรับขนาดด้วยเปอร์เซ็นต์ (Percentage Sizing)**: รองรับการกำหนดมิติด้วยเปอร์เซ็นต์

## บันทึกการเปลี่ยนแปลง

### เวอร์ชัน 1.0.0 - เปิดตัวครั้งแรก
**✅ คุณสมบัติที่ใช้งานได้แล้ว:**
- เอนจินเลย์เอาต์ flex พื้นฐานพร้อมทิศทางแนวนอน (Row) / แนวตั้ง (Column)
- รองรับ Flex Grow สำหรับการปรับขนาดแบบไดนามิก
- โหมดการจัดตำแหน่ง Justify Content ทั้งหมด
- โหมดการจัดตำแหน่ง Align Items ทั้งหมด
- สามารถกำหนดช่องว่าง (gaps) และระยะขอบด้านใน (padding)
- รวมเข้ากับ Visual Designer
- อัปเดตเลย์เอาต์ขณะรันไทม์

**🐛 ปัญหาที่ได้รับการแก้ไข:**
- **นรกของการจัดตำแหน่งด้วยตนเอง (Manual Positioning Hell)**: ขจัดความจำเป็นในการใช้โค้ดปรับขนาดที่ซับซ้อน
- **ระยะห่างไม่สม่ำเสมอ (Inconsistent Spacing)**: ตรรกะการจัดระยะห่างแบบรวมศูนย์ช่วยป้องกันปัญหาช่องว่างหรือการทับซ้อน
- **การออกแบบที่ตอบสนอง (Responsive Design)**: ปรับตามการเปลี่ยนแปลงขนาดคอนเทนเนอร์อัตโนมัติ
- **ภาระการบำรุงรักษา (Maintenance Burden)**: เลย์เอาต์แบบประกาศ (Declarative) ช่วยลดความซับซ้อนของโค้ด

**⚡ การปรับแต่งประสิทธิภาพ:**
- คำนวณเลย์เอาต์แบบรอบเดียว (Single-pass layout calculation)
- การค้นหาค่า flex-grow ด้วย dictionary ที่มีประสิทธิภาพ
- ลดการคำนวณซ้ำระหว่างการทำงานปรับขนาดให้เหลือน้อยที่สุด

### ปัญหาที่ทราบและสิ่งที่พิจารณาในอนาคต
- **ความแม่นยำของจุดทศนิยม (Floating Point Precision)**: มีข้อผิดพลาดในการปัดเศษเล็กน้อยในสถานการณ์ flex-grow ที่ซับซ้อน
- **เลย์เอาต์ซ้อนกัน (Nested Layouts)**: ปัจจุบันยังไม่รองรับ (วางแผนไว้ในเวอร์ชัน 2.0)
- **แอนิเมชัน (Animation)**: ยังไม่มีการรองรับการเปลี่ยนภาพในตัว (วางแผนไว้ในเวอร์ชัน 2.0)

## การทดสอบ

โปรเจ็กต์นี้ครอบคลุมการทดสอบอย่างครบถ้วน:
- **Unit Tests**: อัลกอริทึมของเลย์เอาต์ทั้งหมดและกรณีขอบ (edge cases)
- **Visual Tests**: หน้าต่างตัวอย่างแสดงการกำหนดค่าเลย์เอาต์แบบต่างๆ
- **Performance Tests**: การทดสอบความเครียดด้วยตัวควบคุมจำนวนมาก
- **Edge Case Tests**: เลย์เอาต์ว่างเปล่า, คอนเทนเนอร์ขนาดศูนย์, ค่าที่รุนแรง

## ข้อกำหนด

- **เวอร์ชัน Xojo**: 2023r4 หรือใหม่กว่า
- **แพลตฟอร์มเป้าหมาย**: Desktop (Windows, macOS, Linux)
- **Dependencies**: ไม่มี (เป็นการใช้งานด้วย Xojo ล้วน)

## การร่วมให้ข้อมูล

ไลบรารีนี้ได้รับการออกแบบมาให้ขยายได้ ส่วนสำคัญสำหรับการร่วมให้ข้อมูล:
- เพิ่มโหมดการจัดตำแหน่ง
- การปรับแต่งประสิทธิภาพ
- การปรับปรุงเฉพาะแพลตฟอร์ม
- การปรับปรุงเอกสาร

## ลิขสิทธิ์

โปรเจ็กต์นี้เป็นโอเพ่นซอร์สและใช้งานได้ภายใต้ MIT License

---

**สร้างขึ้นด้วย ❤️ สำหรับชุมชน Xojo**
*ปรับปรุงการจัดเลย์เอาต์แอปพลิเคชันเดสก์ท็อปให้ทันสมัย ด้วย flex container ทีละอัน.*
