# 📚 IFC Libraries Documentation

Tài liệu này mô tả các thư viện được sử dụng trong Speckle Server để đọc và xử lý file IFC (Industry Foundation Classes).

## 📖 Mục lục

1. [Tổng quan](#tổng-quan)
2. [Các thư viện được sử dụng](#các-thư-viện-được-sử-dụng)
3. [So sánh chi tiết](./COMPARISON.md)
4. [Hướng dẫn sử dụng](./USAGE.md)
5. [Tài liệu tham khảo](#tài-liệu-tham-khảo)

---

## Tổng quan

Speckle Server sử dụng **2 hệ thống parser IFC** khác nhau để xử lý file IFC:

| Hệ thống | Package | Ngôn ngữ | Trạng thái |
|----------|---------|----------|------------|
| **web-ifc** | `fileimport-service` | JavaScript/WASM | Legacy |
| **ifcopenshell + speckleifc** | `ifc-import-service` | Python | Khuyến nghị |

---

## Các thư viện được sử dụng

### 1️⃣ web-ifc (JavaScript/WebAssembly)

**Package:** `packages/fileimport-service`

**Import:**
```javascript
import WebIFC from 'web-ifc/web-ifc-api-node.js'
```

**Đặc điểm:**
- Thư viện WebAssembly chạy trong Node.js
- Parse IFC geometry và properties trực tiếp
- Hiệu suất cao nhờ WASM
- Phù hợp cho web và Node.js environments

**Website:** https://ifcjs.io | https://github.com/IFCjs/web-ifc

📖 [Chi tiết về web-ifc](./WEB-IFC.md)

---

### 2️⃣ ifcopenshell + speckleifc (Python)

**Package:** `packages/ifc-import-service`

**Import:**
```python
from speckleifc.main import open_and_convert_file
```

**Dependencies:**
```toml
# pyproject.toml
"specklepy[speckleifc]>=3.0.7"
```

```txt
# requirements.txt
ifcopenshell==0.8.3
```

**Đặc điểm:**
- **ifcopenshell**: Thư viện C++/Python mạnh mẽ, đầy đủ tính năng
- **speckleifc**: Wrapper convert IFC → Speckle objects
- Hỗ trợ đầy đủ IFC2x3 và IFC4
- Tích hợp sẵn với Speckle ecosystem

**Websites:**
- ifcopenshell: https://ifcopenshell.org
- speckleifc: https://github.com/specklesystems/speckleifc

📖 [Chi tiết về ifcopenshell](./IFCOPENSHELL.md)

---

## Kiến trúc tổng quan

```
┌─────────────────────────────────────────────────────────────┐
│                     IFC File Upload                          │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
          ┌───────────────────┴───────────────────┐
          │                                       │
          ▼                                       ▼
┌─────────────────────┐             ┌─────────────────────────┐
│  fileimport-service │             │   ifc-import-service    │
│     (Node.js)       │             │       (Python)          │
└─────────────────────┘             └─────────────────────────┘
          │                                       │
          ▼                                       ▼
┌─────────────────────┐             ┌─────────────────────────┐
│      web-ifc        │             │     ifcopenshell        │
│      (WASM)         │             │    + speckleifc         │
└─────────────────────┘             └─────────────────────────┘
          │                                       │
          └───────────────────┬───────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Speckle Objects                          │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Speckle Server                           │
└─────────────────────────────────────────────────────────────┘
```

---

## Tài liệu tham khảo

### IFC Standard
- [buildingSMART IFC](https://www.buildingsmart.org/standards/bsi-standards/industry-foundation-classes/)
- [IFC Documentation](https://standards.buildingsmart.org/IFC/RELEASE/IFC4/ADD2_TC1/HTML/)

### Thư viện
- [web-ifc GitHub](https://github.com/IFCjs/web-ifc)
- [ifcopenshell GitHub](https://github.com/IfcOpenShell/IfcOpenShell)
- [speckleifc GitHub](https://github.com/specklesystems/speckleifc)
- [specklepy Documentation](https://speckle.guide/dev/py.html)

### Speckle
- [Speckle Documentation](https://speckle.guide/)
- [Speckle Server GitHub](https://github.com/specklesystems/speckle-server)

---

## Đóng góp

Nếu bạn muốn đóng góp vào tài liệu này, vui lòng tạo Pull Request với các thay đổi của bạn.

---

*Cập nhật lần cuối: 2026-04-13*
